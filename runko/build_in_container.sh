#!/bin/bash

script="$(readlink -f "${BASH_SOURCE[0]}")"
dir="$(dirname "$script")"

if [ 2 -ne $# ]
then
    echo "Give two arguments: tyvi OR runko AND cpu OR hip"
    echo "E.g. $0 tyvi cpu"
    exit 1
fi

project=$1
backend=$2

if [ $project != "tyvi" -a $project != "runko" ]
then
    echo "Give either \"tyvi\" or \"runko\" as first argument, not \"$project\""
    exit 1
fi

if [ $backend != "cpu" -a $backend != "hip" ]
then
    echo "Give either \"cpu\" or \"hip\" as second argument, not \"$backend\""
    exit 1
fi

if [ $project == "tyvi" ]
then
    base_dir=/src/external/tyvi
    preset=$backend-debug
fi

if [ $project == "runko" ]
then
    base_dir=/src
    preset=unix-$backend
fi

if [ $backend == "cpu" ]
then
    rocthrust_dir='${ROCTHRUST_INSTALL_PREFIX}/lib/cmake/rocthrust'
else
    rocthrust_dir='/opt/rocm-6.3.4/lib/cmake/rocthrust'
    amdgpu_targets=gfx90a
fi

source_dir=${base_dir}
build_dir=${base_dir}/out/${preset}

$dir/run.sh bash -c "\
    cmake \
        --preset ${preset} \
        -S ${source_dir} \
        -B ${build_dir} \
        -Drocthrust_DIR=${rocthrust_dir} \
        -DAMDGPU_TARGETS=${amdgpu_targets} \
    && \
    cmake --build ${build_dir} -j 10"
