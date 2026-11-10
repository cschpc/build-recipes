#!/bin/bash -l
#SBATCH --account=project_462001358
#SBATCH --partition=standard-g
#SBATCH --job-name=runko-batch-inject-profile
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
module load cray-python
module load Boost/1.90.0-cpeCray-25.09
module load lumi-CrayPath

if [ ! -d ${RUNKODIR} ]
then
    echo "Set the variable RUNKODIR to point to the runko repository directory"
    exit 1
fi

if [ ! -d ${FGDIR} ]
then
    echo "Set the variable FGDIR to point to the FlameGraph repository directory"
    exit 1
fi

source ${RUNKODIR}/venv/bin/activate

export RUNKO_RUNDIR=/tmp/$USER/perf

mkdir -p ${RUNKO_RUNDIR}
cd ${RUNKO_RUNDIR}
cp ${RUNKODIR}/projects/pic-turbulence/pic.py pic.py
cp ${RUNKODIR}/projects/pic-turbulence/*.ini .

# Run only 20 laps
sed -E -i "s/(^[ ]{4}conf.n_laps = )(.*)/\1 20/" pic.py

export OMP_NUM_THREADS=6
export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_GPU_IPC_ENABLED=0

OUTPUT_DIR=/scratch/project_462001358/$USER/flamegraphs/${SLURM_JOB_ID}
fgout=${OUTPUT_DIR}/flamegraph.svg
mkdir -p ${OUTPUT_DIR}

srun perf record -F 1997 -g -o perf.data \
    python pic.py && \
    perf script | ${FGDIR}/stackcollapse-perf.pl | ${FGDIR}/flamegraph.pl > ${fgout}

cd
rm -rf ${RUNKO_RUNDIR}
