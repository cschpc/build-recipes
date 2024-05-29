#!/bin/bash

echo "This script downloads and installs TAU"
echo "It's configured to work on LUMI"
echo "Last update on 2024-05-29"

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

base_conf="-bfd=download -otf=download -unwind=download -dwarf=download -iowrapper -cc=cc -c++=CC -fortran=ftn -pthread -mpi"
python_conf="-python"
papi_conf="-papi=/opt/cray/pe/papi/$papi_version"
rocm_conf="-rocm=/opt/rocm-$rocm_version"
rocprofiler_conf="-rocprofiler=/opt/rocm-$rocm_version/rocprofiler"
roctracer_conf="-roctracer=/opt/rocm-$rocm_version/roctracer"

declare configs
configs=(
    "$base_conf"
    "$base_conf $python_conf"
    "$base_conf $python_conf $papi_conf"
    "$base_conf $python_conf $papi_conf $rocm_conf"
    "$base_conf $python_conf $papi_conf $rocm_conf $rocprofiler_conf"
    "$base_conf $python_conf $papi_conf $rocm_conf $roctracer_conf"
    "$base_conf $papi_conf"
    "$base_conf $papi_conf $rocm_conf"
    "$base_conf $papi_conf $rocm_conf $rocprofiler_conf"
    "$base_conf $papi_conf $rocm_conf $roctracer_conf"
)

for conf in "${configs[@]}"; do
    echo "Configuring and installing with $conf"
    (./configure $conf && make install -j 8) || \
        { echo "Failed to configure and install TAU with $conf"; exit 1; }
done

echo "TAU installation successful!"
