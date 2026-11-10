#!/bin/bash -l

#SBATCH --account=project_462001358
#SBATCH --partition=standard-g
#SBATCH --job-name=build-runko
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --cpus-per-task=56
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=00:20:00

ml LUMI/25.03
ml partition/G
ml PrgEnv-cray
ml rocm/6.3.4
ml craype-accel-amd-gfx90a
ml cray-mpich/8.1.32
ml craype-network-ofi
ml buildtools

# From EB
ml Score-P/9.4-cpeCray-25.03-rocm

if [ ! -d ${RUNKODIR} ]
then
    echo "Set the variable RUNKODIR to point to the runko repository directory"
    exit 1
fi

cd ${RUNKODIR}

# Dependencies should be installed to the virtual environment
# before building runko, including scorep.
source venv/bin/activate

# Which programming paradigms to measure
# This file sets PARADIGMS_USED
source ${RUNKODIR}/profiling/scorep/scorep-paradigms.sh

export SCOREP_WRAPPER_INSTRUMENTER_FLAGS=""
export SCOREP_WRAPPER_INSTRUMENTER_FLAGS="${SCOREP_WRAPPER_INSTRUMENTER_FLAGS} --verbose=2"
export SCOREP_WRAPPER_INSTRUMENTER_FLAGS="${SCOREP_WRAPPER_INSTRUMENTER_FLAGS} ${PARADIGMS_USED}"

INSTRUMENTED_BUILD_DIR=build-instrumented

SCOREP_WRAPPER=off \
cmake \
    --preset=lumi-gpu \
    -B $INSTRUMENTED_BUILD_DIR \
    -S . \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_CXX_COMPILER=scorep-CC \
    -DCMAKE_NO_SYSTEM_FROM_IMPORTED:BOOL=ON \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON

cmake --build $INSTRUMENTED_BUILD_DIR -j 56
