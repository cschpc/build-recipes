#!/bin/bash

modification_date=2024-09-13
authors="Juhana Lankinen, "

# Choose:
# - compiler suite
# - MPI implementation
# - others
compiler="gcc"
mpi="openmpi"
binutils_path="/appl/spack/v020/install-tree/gcc-8.5.0/binutils-2.40-nt5ao6/"
# Set this to empty string to not use cuda
cuda="cuda"

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
    "4.1.5${cuda:+-${cuda}}"
    "7.1.0"
)

# Add cuda to modules, if ${cuda} is not empty
if [ "z${cuda}" != "z" ]
then
    module_names[${#module_names[@]}]="${cuda}"
    module_versions[${#module_versions[@]}]="12.1.1"
fi

# ===================================
# Function definitions for the script
# ===================================

echo_with_lines () {
echo "--------------------------------------------------------------------------------"
echo "${1}"
echo ""
}

echoerr() {
    >&2 cat <<< "$@"
}

fail_with_message() {
    echoerr "$@"
    exit 1
}

download_package() {
    dest_dir=${1}
    url=${2}

    [ -d ${dest_dir} ] || fail_with_message "${dest_dir} is not an existing directory"
    cd ${dest_dir}
    wget ${url} -N || fail_with_message "Couldn't get files from ${url}"
    cd $OLDPWD
}

extract_package() {
    dest_dir=${1}
    tarball=${2}

    [ -d ${dest_dir} ] || fail_with_message "${dest_dir} does not exist or is not a directory"
    [ -e ${tarball} ] || fail_with_message "${tarball} does not exist"

    cd ${dest_dir}

    # Get the extracted directory name
    extracted_dir=$(tar -tzf ${tarball} | head -1 | cut -f1 -d"/") || fail_with_message "Couldn't get extracted dir name with tar"
    tar -xzf ${tarball} --skip-old-files || fail_with_message "Couldn't extract files from tarball ${tarball}"
    [ -d ${extracted_dir} ] || fail_with_message "The (supposedly) extracted directory ${extracted_dir} does not exist or is not a directory"
    
    cd $OLDPWD
    echo ${extracted_dir}
}

configure_install() {
    base_dir=${1}
    config_str=${2}

    [ -d ${base_dir} ] || fail_with_message "${base_dir} is not an existing directory"
    cd ${base_dir}

    mkdir -p build || fail_with_message "Failed to create build dir"
    cd build
    ../configure ${config_str} || fail_with_message "Failed to configure Score-P with ${config_str}"
    make -j 64 || fail_with_message "Failed to make Score-P with ${config_str}"
    make install || fail_with_message "Failed to install Score-P with ${config_str}"
    cd $OLDPWD
}

find_path_of() {
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

    [ -d ${found_path} ] || fail_with_message "Couldn't find path for ${1} from ${2}"

    echo ${found_path}
}

load_modules() {
    [ ${#module_names[@]} == ${#module_versions[@]} ] ||
        fail_with_message "Module names and module versions are different lengths"

    for ((i = 0; i < ${#module_names[@]}; i++))
    do
        module_name=${module_names[i]}
        module_version=${module_versions[i]}
        echo "Loading module ${module_name}/${module_version}"
        ml "${module_name}/${module_version}" || fail_with_message "Couldn't load module ${module_name}/${module_version}"
    done
}

generate_module_string() {
    [ ${#module_names[@]} == ${#module_versions[@]} ] ||
        fail_with_message "Module names and module versions are different lengths"

    for ((i = 0; i < ${#module_names[@]}; i++))
    do
        # Expand $module_str to $module_str- if it's not null, otherwise expand to nothing
        # Then append $module_name-$module_version to it
        module_name=${module_names[i]}
        module_version=${module_versions[i]}
        module_str="${module_str:+${module_str}-}${module_name}-${module_version}"
    done

    echo ${module_str}
}

# =============================
# Begin execution of the script
# =============================

echo_with_lines "This script downloads and installs Score-P. It's configured to work on Mahti. Last update on $modification_date"

[ $# -eq 3 ] || {
    echoerr "Usage: ${0} /path/to/build/dir /path/to/install/dir scorep-version";
    fail_with_message "E.g. ${0} /scratch/project_2002078/apps /projappl/project_2002078/apps 8.4";
}
[ -d "${1}" ] || fail_with_message "${1} is not an existing directory"
[ -d "${2}" ] || fail_with_message "${2} is not an existing directory"

version_number_regexp='^[0-9]+([.][0-9]+)*$'
[[ "${3}" =~ ${version_number_regexp} ]] || fail_with_message "${3} is not a valid version number"

echo_with_lines "Load modules and generate directory name"
load_modules || fail_with_message "Failed to load modules"
module_str=$(generate_module_string) || fail_with_message "Failed to generate module string"

echo_with_lines "Create build and install directories"
scorep_version=${3}
scorep_tarball=scorep-${scorep_version}.tar.gz
scorep_url=https://perftools.pages.jsc.fz-juelich.de/cicd/scorep/tags/scorep-${scorep_version}/${scorep_tarball}

build_dir=$(realpath ${1})/scorep
mkdir -p ${build_dir} || fail_with_message "Couldn't create directory ${build_dir}"

install_dir=$(realpath ${2})/scorep/scorep-${scorep_version}-${module_str}
mkdir -p ${install_dir} || fail_with_message "Couldn't create directory ${install_dir}"

echo_with_lines "Downloading Score-P"
download_package ${build_dir} ${scorep_url} || fail_with_message "Failed to donwload package from ${scorep_url}"

echo_with_lines "Extracting Score-P"
build_dir=${build_dir}/$(extract_package ${build_dir} ${scorep_tarball}) || fail_with_message "Failed to extract package from ${scorep_tarball}"
echo "Using ${build_dir} as the build and ${install_dir} as the installation directory"

echo_with_lines "Configuring and installing Score-P"
papi_path=$(find_path_of "papi" ${LIBRARY_PATH}) || fail_with_message "Failed to find papi path from ${LIBRARY_PATH}"

if [ "z${cuda}" != "z" ]
then
    cuda_path=$(find_path_of "${cuda}" ${LIBRARY_PATH}) || fail_with_message "Failed to find ${cuda} path from ${LIBRARY_PATH}"
fi

# Add Score-P configuration options for different configurations
declare -a config_options
config_options=(
    "--with-nocross-compiler-suite=${compiler}"
    "--with-mpi=${mpi}"
    "--with-papi-headers=${papi_path}/include --with-papi-lib=${papi_path}/lib"
    "--with-libbfd=${binutils_path}"
    "--without-cubew"
    "--without-cubelib"
)

# Add cuda specific options
if [ "z${cuda_path}" != "z" ]
then
    config_options[${#config_options[@]}]="--with-libcudart-include=${cuda_path}/include"
    config_options[${#config_options[@]}]="--with-libcudart-lib=${cuda_path}/lib64"
    config_options[${#config_options[@]}]="--with-libcupti-include=${cuda_path}/extras/CUPTI/include"
    config_options[${#config_options[@]}]="--with-libcupti-lib=${cuda_path}/extras/CUPTI/lib64"
fi

config_str="--prefix=${install_dir}"

for ((i = 0; i < ${#config_options[@]}; i++))
do
    config_str="${config_str} ${config_options[i]}"
done

configure_install ${build_dir} "${config_str}"

echo_with_lines "Score-P installation successful!"
