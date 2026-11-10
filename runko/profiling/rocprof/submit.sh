#!/bin/bash -l
#SBATCH --account=project_462001358
#SBATCH --partition=standard-g
#SBATCH --job-name=runko-rocprof-trace
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --gpus-per-node=8
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

source ${RUNKODIR}/venv/bin/activate

export RUNKO_RUNDIR=/tmp/$USER/rocprof-trace-run

mkdir -p ${RUNKO_RUNDIR}
cd ${RUNKO_RUNDIR}
cp ${RUNKODIR}/projects/pic-turbulence/pic.py pic.py
cp ${RUNKODIR}/projects/pic-turbulence/*.ini .

# Run only 100 laps
sed -E -i "s/(^[ ]{4}conf.n_laps = )(.*)/\1 100/" pic.py

cat << EOF > select_gpu
#!/bin/bash
export ROCR_VISIBLE_DEVICES=\$SLURM_LOCALID

exec \$*
EOF

chmod +x ./select_gpu

CPU_BIND="mask_cpu:7e000000000000,7e00000000000000"
CPU_BIND="${CPU_BIND},7e0000,7e000000"
CPU_BIND="${CPU_BIND},7e,7e00"
CPU_BIND="${CPU_BIND},7e00000000,7e0000000000"

export OMP_NUM_THREADS=6
export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_GPU_IPC_ENABLED=0

export OUTPUT_DIR=/scratch/project_462001358/$USER/runko_profiles/${SLURM_JOB_ID}_rocprof_trace
mkdir -p $OUTPUT_DIR

ROCPROFV3="rocprofv3"
ROCPROFV3="${ROCPROFV3} --sys-trace"
#ROCPROFV3="${ROCPROFV3} --collection-period 60:1:5"
ROCPROFV3="${ROCPROFV3} --output-format pftrace"
ROCPROFV3="${ROCPROFV3} --output-directory ${OUTPUT_DIR}"
ROCPROFV3="${ROCPROFV3} --output-file %launch_time%-%hostname%-%pid%-%rank%.pftrace"
ROCPROFV3="${ROCPROFV3} --"

deps_base=${RUNKODIR}/build/editable-RelWithDebInfo-cp311-cp311-linux_x86_64
export LD_LIBRARY_PATH=${deps_base}/external/tyvi/src:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${deps_base}/_deps/pika-build/lib:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${deps_base}/_deps/spdlog-build:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${deps_base}/_deps/fmt-build:${LD_LIBRARY_PATH}

srun --cpu-bind=${CPU_BIND} ./select_gpu ${ROCPROFV3} python pic.py

rm -f ./select_gpu
cd
rm -rf ${RUNKO_RUNDIR}
