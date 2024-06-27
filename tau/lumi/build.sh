#!/bin/bash

modification_date=2024-06-27
authors="Juhana Lankinen, "

# Change the versions as newer become available
lumi_version=23.09
python_version=3.10.10
rocm_version=5.4.6
papi_version=7.0.1.1
gnu_version=8.4.0

echo_with_lines () {
echo "--------------------------------------------------------------------------------"
echo "$1"
echo "--------------------------------------------------------------------------------"
}

download_and_extract() {
    dir=$1
    tarball=$2
    url=$3

    [ ! -d "$dir" ] || { echo "$dir already exists. Use a fresh directory."; exit 1; }
    mkdir -p $dir || { echo "Failed to create directory $dir"; exit 1; }
    echo "Downloading $tarball from $url"
    wget $url -N || { echo "Couldn't get files from $url"; exit 1; }
    echo "Extacting $tarball to $dir"
    tar -xzf $tarball -C $dir --strip-components=2 || { echo "Couldn't extract files from tarball $tarball"; exit 1; }
}

configure_install() {
    echo_with_lines "Configuring and installing with $1"
    (./configure $1 && make install -j 8) || \
        { echo "Failed to configure and install TAU with $1"; exit 1; }
}

echo_with_lines "This script downloads and installs TAU. It's configured to work on LUMI. Last update on $modification_date"

version_number_regexp='^[0-9]+([.][0-9]+)*$'

([ $# -eq 3 ] && \
    [ -d "$1" ] && \
    [[ "$2" =~ $version_number_regexp ]] && \
    [[ "$3" =~ $version_number_regexp ]]) || \
    { echo "Usage: $0 /path/to/install/dir tau-version pdt-version"; \
        echo "E.g. \"$0 /projappl/project_465001194/apps 2.33.2 3.25.1\"";
        exit 1; }

base_dir=$(realpath $1)/tau
mkdir -p $base_dir
cd $base_dir

echo_with_lines "Downloading and extracting PDT and TAU"
tau_version=$2
tau_dir=$base_dir/$tau_version
tau_tarball=tau-$tau_version.tar.gz
tau_url=https://www.cs.uoregon.edu/research/tau/tau_releases/$tau_tarball
download_and_extract $tau_dir $tau_tarball $tau_url

pdt_version=$3
pdt_dir=$base_dir/pdtoolkit
pdt_tarball=pdtoolkit-$pdt_version.tar.gz
pdt_url=https://www.cs.uoregon.edu/research/tau/pdt_releases/$pdt_tarball
download_and_extract $pdt_dir $pdt_tarball $pdt_url

ml LUMI/$lumi_version
ml partition/C
ml PrgEnv-gnu/$gnu_version
ml cray-python/$python_version

cd $pdt_dir

echo_with_lines "Configuring and installing PDT"
{ ./configure && make -j 8 && make install -j 8; } || \
    { echo "Failed to install PDT"; exit 1; }

cd $tau_dir

echo "Hack: Adding C/C++ std libraries to TAU_LINKER_OPT2 so compiling fortran with tau works"
make_skel_files=$(find $tau_dir -name "Makefile.skel")
for file in $make_skel_files
do
    sed -i "s/^\(TAU_LINKER_OPT2.*\)/\1 -lstdc++/g" $file
done

echo_with_lines "Configuring and installing TAU"

compiler_conf="-cc=cc -c++=CC -fortran=ftn"
io_conf="-iowrapper"
downloads_conf="-bfd=download -otf=download -unwind=download -dwarf=download"
pdt_conf="-pdt=$pdt_dir"
papi_conf="-papi=/opt/cray/pe/papi/$papi_version"
pthread_conf="-pthread"
omp_conf="-openmp"
python_conf="-python"
mpi_conf="-mpi"

common="$downloads_conf $io_conf $compiler_conf $pdt_conf $papi_conf $mpi_conf $python_conf"

# Configure for CPU
configure_install "$common $pthread_conf"
#configure_install "$common $omp_conf"
#
## Configure for GPU
#ml partition/G
#ml rocm/$rocm_version
#
#rocm_path=/appl/lumi/SW/LUMI-$lumi_version/G/EB/rocm/$rocm_version
#[ -d $rocm_path ] || { echo "$rocm_path is not a directory"; exit 1; }
#
#rocprofiler_conf="-rocprofiler=$rocm_path/rocprofiler"
#roctracer_conf="-roctracer=$rocm_path/roctracer"
#rocm_conf="-rocm=$rocm_path $rocprofiler_conf $roctracer_conf"
#
#configure_install "$common $rocm_conf $pthread_conf"
#configure_install "$common $rocm_conf $omp_conf"

echo_with_lines "TAU installation successful!"
