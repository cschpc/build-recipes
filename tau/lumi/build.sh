#!/bin/bash

# N.B. This script is not very robust with reinstallations
# If you need to reinstall tau, it's probably best to remove the old directory altogether
# and then rerun this script

echo_with_lines () {
echo "--------------------------------------------------------------------------------"
echo "$1"
echo "--------------------------------------------------------------------------------"
}


modification_date=2024-06-11
authors="Juhana Lankinen, "

echo_with_lines "This script downloads and installs TAU. It's configured to work on LUMI. Last update on $modification_date"

# Check arguments
version_number_regexp='^[0-9]+([.][0-9]+)*$'
([ $# -eq 2 ] && [ -d "$1" ] && [[ "$2" =~ $version_number_regexp ]]) || \
    { echo "Usage: $0 /path/to/install/dir tau version"; \
        echo "E.g. \"$0 /projappl/project_462000007/$USER/apps 2.33\"";
        exit 1; }

base_dir=$(realpath $1)
tau_dir=$base_dir/tau
version=$2

mkdir -p $tau_dir || \
    { echo "Failed to create directory $tau_dir"; exit 1; }

cd $tau_dir

echo_with_lines "Loading modules"
# Change the versions as newer become available
lumi_version=23.09
python_version=3.10.10
rocm_version=5.4.6
papi_version=7.0.1.1
gnu_version=8.4.0

ml LUMI/$lumi_version
ml partition/G
ml cray-python/$python_version
ml rocm/$rocm_version
ml PrgEnv-gnu/$gnu_version

rocm_path=/appl/lumi/SW/LUMI-$lumi_version/G/EB/rocm/$rocm_version
[ -d $rocm_path ] || { echo "$rocm_path is not a directory"; exit 1; }

echo_with_lines "Downloading PDT"
pdt_tarball=pdt_lite.tgz
pdt_url=http://tau.uoregon.edu/$pdt_tarball
pdt_dir=$tau_dir/pdtoolkit

wget $pdt_url -N || \
    { echo "Couldn't get files from $pdt_url"; exit 1; }

mkdir -p $pdt_dir || \
    { echo "Failed to create directory $pdt_dir"; exit 1; }

tar -xzf $pdt_tarball -C $pdt_dir --strip-components=2 --skip-old-files || \
    { echo "Couldn't extract files from tarball $pdt_tarball"; exit 1; }

cd $pdt_dir

echo_with_lines "Installing pdt"
{ ./configure && make -j 8 && make install -j 8; } || \
    { echo "Failed to install PDT"; exit 1; }

cd $tau_dir

echo_with_lines "Downloading TAU"
tau_tarball=tau-$version.tar.gz
tau_url=https://www.cs.uoregon.edu/research/tau/tau_releases/$tau_tarball
install_dir=$tau_dir/$version

wget $tau_url -N || \
    { echo "Couldn't get files from $tau_url"; exit 1; }

mkdir -p $install_dir || \
    { echo "Failed to create directory $install_dir"; exit 1; }

tar -xzf $tau_tarball -C $install_dir --strip-components=2 --skip-old-files || \
    { echo "Couldn't extract files from tarball $tau_tarball"; exit 1; }

cd $install_dir

echo_with_lines "Configuring and installing"
base_compiler_conf="-cc=cc -c++=CC -fortran=ftn"
io_conf="-iowrapper"
base_conf="-bfd=download -otf=download -unwind=download -dwarf=download"
pthread_conf="-pthread"
omp_conf="-openmp"
python_conf="-python"
mpi_conf="-mpi"
papi_conf="-papi=/opt/cray/pe/papi/$papi_version"
rocm_conf="-rocm=$rocm_path"
rocprofiler_conf="-rocprofiler=$rocm_path/rocprofiler"
roctracer_conf="-roctracer=$rocm_path/roctracer"
pdt_conf="-pdt=$pdt_dir"
external_packages_conf="$papi_conf $rocm_conf $rocprofiler_conf $roctracer_conf $pdt_conf"

declare configs
configs=(
    "$base_conf $io_conf $base_compiler_conf $external_packages_conf"
    "$base_conf $io_conf $base_compiler_conf $external_packages_conf $pthread_conf"
    "$base_conf $io_conf $base_compiler_conf $external_packages_conf $pthread_conf $mpi_conf"
    "$base_conf $io_conf $base_compiler_conf $external_packages_conf $pthread_conf $mpi_conf $python_conf"
    "$base_conf $io_conf $base_compiler_conf $external_packages_conf $omp_conf"
    "$base_conf $io_conf $base_compiler_conf $external_packages_conf $omp_conf $mpi_conf"
    "$base_conf $io_conf $base_compiler_conf $external_packages_conf $omp_conf $mpi_conf $python_conf"
)

for conf in "${configs[@]}"; do
    echo_with_lines "Configuring and installing with $conf"
    (./configure $conf && make install -j 8) || \
        { echo "Failed to configure and install TAU with $conf"; exit 1; }
done

echo_with_lines "TAU installation successful!"
