#!/bin/bash

ml PrgEnv-amd
ml craype-x86-trento 
ml craype-accel-amd-gfx90a
ml rocm

export HIPCC_COMPILE_FLAGS_APPEND="--offload-arch=gfx90a $(CC --cray-print-opts=cflags)"
export HIPCC_LINK_FLAGS_APPEND=$(CC --cray-print-opts=libs)

set -eaux

kokkos_version=4.5.01
account=project_462000007
src_dir=kokkos-$kokkos_version
build_dir=/flash/$account/$USER/kokkos-$kokkos_version/build
install_dir=/scratch/$account/$USER/kokkos-$kokkos_version/

wget https://github.com/kokkos/kokkos/releases/download/$kokkos_version/kokkos-$kokkos_version.tar.gz
tar xzf kokkos-$kokkos_version.tar.gz

mkdir -p $build_dir
mkdir -p $install_dir

cmake \
    -S $src_dir \
    -B $build_dir\
    -DCMAKE_CXX_COMPILER=hipcc \
    -DCMAKE_BUILD_TYPE=Release \
    -DKokkos_ENABLE_HIP=ON \
    -DKokkos_ARCH_AMD_GFX90A=ON \
    -DKokkos_ENABLE_OPENMP=ON \
    -DCMAKE_INSTALL_PREFIX=$install_dir

cmake \
    --build $build_dir \
    --target install \
    --parallel 4
