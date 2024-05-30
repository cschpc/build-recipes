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

# Check if the second argument is a version number
re='^[0-9]+([.][0-9]+)*$'
if [ $# -eq 2 ] && [[ "$2" =~ $re ]]
then
    version=$2
else
    version=latest
fi

install_dir=$tau_dir/$version

mkdir -p $tau_dir || \
    { echo "Failed to create directory $tau_dir"; exit 1; }

cd $tau_dir
echo "Downloading TAU"

if [ "$version" = "latest" ]
then
    tau_tarball=tau.tgz
    tau_url=https://www.cs.uoregon.edu/research/tau/$tau_tarball
else
    tau_tarball=tau-$version.tar.gz
    tau_url=https://www.cs.uoregon.edu/research/tau/tau_releases/$tau_tarball
fi

wget $tau_url -N || \
    { echo "Couldn't get tau from $tau_url"; exit 1; }

mkdir -p $install_dir || \
    { echo "Failed to create directory $install_dir"; exit 1; }

tar -xf $tau_tarball -C $install_dir --strip-components=2 --skip-old-files || \
    { echo "Couldn't extract files from tarball $tau_tarball"; exit 1; }

cd $install_dir

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

compiler_conf="-cc=cc -c++=CC -fortran=ftn"
io_conf="-iowrapper"

base_conf="-bfd=download -otf=download -unwind=download -dwarf=download $io_conf $compiler_conf"

pthread_conf="-pthread"
omp_conf="-openmp"

python_conf="-python"
mpi_conf="-mpi"

papi_conf="-papi=/opt/cray/pe/papi/$papi_version"
rocm_conf="-rocm=/opt/rocm-$rocm_version"
rocprofiler_conf="-rocprofiler=/opt/rocm-$rocm_version/rocprofiler"
roctracer_conf="-roctracer=/opt/rocm-$rocm_version/roctracer"
pdt_conf="-pdt=download"
external_packages_conf="$papi_conf $rocm_conf $rocprofiler_conf $roctracer_conf $pdt_conf"

declare configs
configs=(
    "$base_conf" "$external_packages_conf"
    "$base_conf" "$external_packages_conf" "$pthread_conf"
    "$base_conf" "$external_packages_conf" "$pthread_conf" "$mpi_conf"
    "$base_conf" "$external_packages_conf" "$pthread_conf" "$mpi_conf" "$python_conf"
    "$base_conf" "$external_packages_conf" "$omp_conf"
    "$base_conf" "$external_packages_conf" "$omp_conf" "$mpi_conf"
    "$base_conf" "$external_packages_conf" "$omp_conf" "$mpi_conf" "$python_conf"
)

for conf in "${configs[@]}"; do
    echo "Configuring and installing with $conf"
    (./configure $conf && make install -j 8) || \
        { echo "Failed to configure and install TAU with $conf"; exit 1; }
done

echo "TAU installation successful!"
