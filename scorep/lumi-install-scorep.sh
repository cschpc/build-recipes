#!/bin/bash -l

#SBATCH --account=project_xxxxxxxxx
#SBATCH --partition=standard-g
#SBATCH --job-name=build-scorep
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --cpus-per-task=56
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=03:00:00

ml LUMI/25.09
ml partition/G
ml PrgEnv-cray
ml rocm/6.4.4
ml craype-accel-amd-gfx90a
ml cray-mpich/9.0.1
ml craype-network-ofi
ml buildtools
ml cray-python
ml papi/7.2.0.2
ml lumi-CrayPath

set -ex

# Run these first on a login node: compute nodes don't have wget (?)
#cd /path/to/base/dir
#wget https://perftools.pages.jsc.fz-juelich.de/cicd/scorep/tags/scorep-9.4/scorep-9.4.tar.gz
#tar -xzf scorep-9.4.tar.gz

BUILD_DIR=/projappl/project_xxxxxxxxx/scorep-9.4/_build/
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

# 1. scorep-9.4/INSTALL says --with-papi-header and --with-papi-lib are deprecated
#    and recommends using --with-libpapi or --with-libpapi-include and --with-libpapi-lib
#    but they don't seem to work: the configure script does not find (?) papi.h
#    even if the path is exactly the same as given here.
#
# 2. libbfd found in /opt/cray/pe/cce/20.0.0/binutils/x86_64/lib/
#    is not usable, as it's a static archive and Score-P wants a shared/PIC library
#    and I didn't find a shared library anywhere, so it's downloaded.
#
# 3. --enable-shared, --disable-static and --disable-llvm-plugin were taken from
#    the example EB recipe here:
#    https://lumi-supercomputer.github.io/LUMI-EasyBuild-docs/s/
#       Score-P/Score-P-9.4-cpeCray-25.03-rocm/
#
../configure \
    --prefix=/projappl/project_xxxxxxxxx/scorep \
    --enable-shared \
    --disable-static \
    --disable-llvm-plugin \
    --with-rocm=/appl/lumi/SW/LUMI-25.09/G/EB/rocm/6.4.4 \
    --with-nocross-compiler-suite=cray \
    --with-mpi=cray \
    --with-shmem=cray \
    --with-papi-header=$CRAY_PAPI_PREFIX/include \
    --with-papi-lib=$CRAY_PAPI_PREFIX/lib \
    --with-libunwind-include=/opt/cray/pe/perftools/25.09.0/include \
    --with-libunwind-lib=/opt/cray/pe/perftools/25.09.0/lib/libunwind \
    --with-libpmi=/opt/cray/pe/pmi/6.1.16 \
    --with-libbfd=download \
    --with-libgotcha=download

make -j 56
make install
