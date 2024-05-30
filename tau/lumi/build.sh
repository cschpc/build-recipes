#!/bin/bash

modification_date=2024-05-30
authors="Juhana Lankinen, "

echo "This script downloads and installs TAU"
echo "It's configured to work on LUMI"
echo "Last update on $modification_date"

if [ $# -eq 0 ] || [ ! -d "$1" ]
then
    echo "Usage: $0 /path/to/install/dir [tau version]"
    echo "E.g. \"$0 /projappl/project_462000007/$USER/apps 2.33\""
    echo "Or \"$0 /projappl/project_462000007/$USER/apps\" to install the latest version"
    exit 1
fi

base_dir=$(realpath $1)
tau_dir=$base_dir/tau

mkdir -p $tau_dir || \
    { echo "Failed to create directory $tau_dir"; exit 1; }

cd $tau_dir

echo "Downloading PDT"
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
echo "Installing pdt"
{ ./configure && make -j 8 && make install -j 8; } || \
    { echo "Failed to install PDT"; exit 1; }

cd $tau_dir

echo "Downloading TAU"
# Check if the second argument is a version number
re='^[0-9]+([.][0-9]+)*$'
if [ $# -eq 2 ] && [[ "$2" =~ $re ]]
then
    version=$2
else
    version=latest
fi

if [ "$version" = "latest" ]
then
    tau_tarball=tau.tgz
    tau_url=https://www.cs.uoregon.edu/research/tau/$tau_tarball
else
    tau_tarball=tau-$version.tar.gz
    tau_url=https://www.cs.uoregon.edu/research/tau/tau_releases/$tau_tarball
fi

install_dir=$tau_dir/$version

wget $tau_url -N || \
    { echo "Couldn't get files from $tau_url"; exit 1; }

mkdir -p $install_dir || \
    { echo "Failed to create directory $install_dir"; exit 1; }

tar -xzf $tau_tarball -C $install_dir --strip-components=2 --skip-old-files || \
    { echo "Couldn't extract files from tarball $tau_tarball"; exit 1; }

cd $install_dir

echo "Downloading external dependencies"
ext_deps_tarball=ext.tgz
ext_deps_url=http://tau.uoregon.edu/$ext_deps_tarball
wget $ext_deps_url -N || \
    { echo "Couldn't get files from $ext_deps_url"; exit 1; }

tar -xzf $ext_deps_tarball --skip-old-files || \
    { echo "Couldn't extract files from tarball $ext_deps_tarball"; exit 1; }

echo "Loading modules"
# Change the versions as newer become available
lumi_version=23.09
python_version=3.10.10
rocm_version=5.2.3
gnu_version=8.4.0
papi_version=7.0.1.1

ml LUMI/$lumi_version
ml partition/G
ml cray-python/$python_version
ml PrgEnv-gnu/$gnu_version
ml craype-accel-amd-gfx90a
ml rocm/$rocm_version

echo "Configuring and installing"

base_compiler_conf="-cc=cc -c++=CC -fortran=ftn"
mpi_compiler_conf="-cc=mpicc -c++=mpicxx -fortran=mpif90"
io_conf="-iowrapper"
base_conf="-bfd=download -otf=download -unwind=download -dwarf=download"
pthread_conf="-pthread"
omp_conf="-openmp"
python_conf="-python"
mpi_conf="-mpi"
papi_conf="-papi=/opt/cray/pe/papi/$papi_version"
rocm_conf="-rocm=/opt/rocm-$rocm_version"
rocprofiler_conf="-rocprofiler=/opt/rocm-$rocm_version/rocprofiler"
roctracer_conf="-roctracer=/opt/rocm-$rocm_version/roctracer"
pdt_conf="-pdt=$pdt_dir"
external_packages_conf="$papi_conf $rocm_conf $rocprofiler_conf $roctracer_conf $pdt_conf"

declare configs
configs=(
    "$base_conf $io_conf $base_compiler_conf $external_packages_conf"
    "$base_conf $io_conf $base_compiler_conf $external_packages_conf $pthread_conf"
    "$base_conf $io_conf $mpi_compiler_conf  $external_packages_conf $pthread_conf $mpi_conf"
    "$base_conf $io_conf $mpi_compiler_conf  $external_packages_conf $pthread_conf $mpi_conf $python_conf"
    "$base_conf $io_conf $base_compiler_conf $external_packages_conf $omp_conf"
    "$base_conf $io_conf $mpi_compiler_conf  $external_packages_conf $omp_conf $mpi_conf"
    "$base_conf $io_conf $mpi_compiler_conf  $external_packages_conf $omp_conf $mpi_conf $python_conf"
)

for conf in "${configs[@]}"; do
    echo "Configuring and installing with $conf"
    (./configure $conf && make install -j 8) || \
        { echo "Failed to configure and install TAU with $conf"; exit 1; }
done

echo "TAU installation successful!"
