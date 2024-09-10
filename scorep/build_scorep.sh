#!/bin/bash

modification_date=2024-09-10
authors="Juhana Lankinen, "

# Choose:
# - compiler suite
# - MPI implementation
# - others
compiler="gcc"
mpi="openmpi"

# List loaded modules and their versions
declare -a module_names
module_names=(
    "${compiler}"
    "${mpi}"
    "papi"
)

declare -a module_versions
module_versions=(
    "13.1.0"
    "4.1.5"
    "7.1.0"
)

echo_with_lines () {
echo "--------------------------------------------------------------------------------"
echo "${1}"
echo "--------------------------------------------------------------------------------"
}

download_and_extract() {
    dir=${1}
    tarball=${2}
    url=${3}

    [ ! -d "${dir}" ] || { echo "${dir} already exists. Use a fresh directory."; exit 1; }
    mkdir -p ${dir} || { echo "Failed to create directory ${dir}"; exit 1; }
    echo "Downloading ${tarball} from ${url}"
    wget ${url} -N || { echo "Couldn't get files from ${url}"; exit 1; }
    echo "Extacting ${tarball} to ${dir}"
    tar -xzf ${tarball} -C ${dir} --strip-components=1 || { echo "Couldn't extract files from tarball ${tarball}"; exit 1; }
}

configure_install() {
    echo_with_lines "Configuring and installing Score-P with ${1}"
    mkdir -p build || { echo "Failed to create build dir"; exit 1; }
    cd build
    ../configure ${1} || { echo "Failed to configure Score-P with ${1}"; exit 1; }
    make -j 64 || { echo "Failed to make Score-P with ${1}"; exit 1; }
    make install ||  { echo "Failed to install Score-P with ${1}"; exit 1; }
}

found_path=""
find_path_of() {
    echo_with_lines "Attempting to find path of ${1} from ${2}"

    # This gawk function assumes we're given a string that contains paths separated by ':'
    # E.g. "/some/path:/another/path:/a/third/path/with/the/patter/and/subdirs"
    # It'll first split the string by the path separator ':'
    # Then it'll loop over the individual paths and look for a match with a pattern
    # If the pattern was found, the path is split by the directory separator '/'
    # The directories are then looped over backwards until we find the last
    # (so first when going backwards) match with the pattern.
    # Then a substring of the path is returned where everything following the pattern is removed
    # E.g. "batman" "/path/to/superman:/path/to/batman/and/robin:/another/path/to/batman" returns
    # "/path/to/batman"
    
    found_path=$(
        echo "${2}" |
        gawk -F: -v pattern="${1}" '{
            # Loop over the paths
            for (path_idx = 1; path_idx <= NF; path_idx++) {

                # Does the path contain the pattern we are looking for?
                if (match($path_idx, pattern)) {

                    separator = "/"
                    num_directories = split($path_idx, directories, separator)
                    substr_len = length($path_idx)

                    # Loop backwards over the directories
                    for (dir_index = num_directories; dir_index > 0; dir_index--) {
                        if (match(directories[dir_index], pattern)) {
                            break
                        }

                        # The subdirectory does not contain the pattern
                        # Remove its length from the total length
                        # Also remove the length of the separator
                        substr_len = substr_len - length(directories[dir_index]) - length(separator)
                    }
                    print substr($path_idx, 1, substr_len)
                    break
                }
            }
        }'
    )
    echo_with_lines "Using ${found_path} as path for ${1}"
}

module_str=""
load_modules_and_generate_module_string() {
    [ ${#module_names[@]} == ${#module_versions[@]} ] ||
        { echo "Module names and module versions are different lengths"; exit 1; }

    for ((i = 0; i < ${#module_names[@]}; i++))
    do
        # Expand $module_str to $module_str- if it's not null, otherwise expand to nothing
        # Then append $module_name-$module_version to it
        module_name=${module_names[i]}
        module_version=${module_versions[i]}
        module_str="${module_str:+${module_str}-}${module_name}-${module_version}"
        echo "Loading module ${module_name}/${module_version}"
        ml "${module_name}/${module_version}"
    done
}

echo_with_lines "This script downloads and installs Score-P. It's configured to work on Mahti. Last update on $modification_date"
version_number_regexp='^[0-9]+([.][0-9]+)*$'

([ $# -eq 2 ] && \
    [ -d "${1}" ] && \
    [[ "${2}" =~ ${version_number_regexp} ]]) || \
    { echo "Usage: ${0} /path/to/install/dir scorep-version"; \
        echo "E.g. \"${0} /projappl/project_2002078/apps 8.4\"";
        exit 1; }

base_dir=$(realpath ${1})/scorep
mkdir -p ${base_dir}
cd ${base_dir}

echo_with_lines "Load modules and generate directory name"
load_modules_and_generate_module_string

echo_with_lines "Downloading and extracting Score-P"
scorep_version=${2}
scorep_dir=${base_dir}/scorep_${scorep_version}-${module_str}
echo "Using ${scorep_dir} as the installation directory"
scorep_tarball=scorep-${scorep_version}.tar.gz
scorep_url=https://perftools.pages.jsc.fz-juelich.de/cicd/scorep/tags/scorep-${scorep_version}/${scorep_tarball}
download_and_extract ${scorep_dir} ${scorep_tarball} ${scorep_url}

echo_with_lines "Configuring and installing Score-P"
cd ${scorep_dir}
find_path_of "papi" "${LIBRARY_PATH}"

# Add Score-P configuration options for different configurations
declare -a config_options
config_options=(
    "--with-nocross-compiler-suite=${compiler}"
    "--with-mpi=${mpi}"
    "--with-papi-headers=${found_path}/include --with-papi-lib=${found_path}/lib"
    "--with-libbfd=download"
)
config_str="--prefix=${scorep_dir}"

for ((i = 0; i < ${#config_options[@]}; i++))
do
    config_str="${config_str} ${config_options[i]}"
done

configure_install "${config_str}"

echo_with_lines "Score-P installation successful!"
