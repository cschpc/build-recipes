#!/bin/bash -l
#SBATCH --account=project_462001358
#SBATCH --partition=standard-g
#SBATCH --job-name=runko-rocprof-trace
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=0-03:00:00       # Run time (d-hh:mm:ss)

module load LUMI/25.09
module load partition/G
module load PrgEnv-cray
module load rocm/6.4.4
module load craype-accel-amd-gfx90a
module load cray-mpich/9.0.1
module load craype-network-ofi
module load buildtools
module load lumi-CrayPath

set -e
EXPERIMENT=rocprof-pmcs

if [ ! -d ${RUNKODIR} ]
then
    echo "Set the variable RUNKODIR to point to the runko repository directory"
    exit 1
fi

source ${RUNKODIR}/venv/bin/activate

export RUNKO_RUNDIR=/tmp/${USER}/rocprof-pmc

mkdir -p ${RUNKO_RUNDIR}
cd ${RUNKO_RUNDIR}
cp ${RUNKODIR}/profiling/${EXPERIMENT}/pic.py pic.py

export OMP_NUM_THREADS=6
export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_GPU_IPC_ENABLED=0

TARFILE=rocprof-counter.tar.gz

for BLOCKSIZE in 64 128 256 512 1024
do
    sed -i "s/\(^[ ]\{2\}\)\(launch\.template operator()<\)[0-9a-z]*\(,.*\)/\1\2${BLOCKSIZE}u\3/" ${RUNKODIR}/src/runko/pic/particle_current_zigzag_1st.c++
    for STORE in "store_direct" "store_reduced"
    do
        OUTPUT_DIR=/scratch/project_462001358/$USER/runko_profiles/${SLURM_JOB_ID}-${EXPERIMENT}/${STORE}-${BLOCKSIZE}
        mkdir -p $OUTPUT_DIR

        sed -i "s/\(^[ ]\{8\}\)store_[a-z]*\(.*\)/\1${STORE}\2/" ${RUNKODIR}/src/runko/pic/particle_current_shared_mem.h
        pip install --no-build-isolation -v -e ${RUNKODIR} --config-settings=cmake.args=--preset=lumi-gpu
        srun rocprofv3 -i ${RUNKODIR}/profiling/${EXPERIMENT}/counters.yaml -- python pic.py
        tar -czf ${TARFILE} pass_*
        mv ${TARFILE} ${OUTPUT_DIR}
        rm -rf pass_*
    done
done

cd
rm -rf ${RUNKO_RUNDIR}
