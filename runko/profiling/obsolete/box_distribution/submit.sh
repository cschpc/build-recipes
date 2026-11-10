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

if [ ! -d ${RUNKODIR} ]
then
    echo "Set the variable RUNKODIR to point to the runko repository directory"
    exit 1
fi

source ${RUNKODIR}/venv/bin/activate

export RUNKO_RUNDIR=/tmp/$USER/rocprof-trace-run

mkdir -p ${RUNKO_RUNDIR}
cd ${RUNKO_RUNDIR}
cp ${RUNKODIR}/profiling/rocprof/pic.py pic.py

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
ROCPROFV3="${ROCPROFV3} --collection-period 60:1:5"
ROCPROFV3="${ROCPROFV3} --output-format pftrace"
ROCPROFV3="${ROCPROFV3} --output-directory ${OUTPUT_DIR}"
ROCPROFV3="${ROCPROFV3} --output-file %launch_time%-%hostname%-%pid%-%rank%.pftrace"
ROCPROFV3="${ROCPROFV3} --"

#srun --cpu-bind=${CPU_BIND} ./select_gpu ${ROCPROFV3} python pic.py
#srun ${ROCPROFV3} python pic.py
#srun python pic.py
#mv indices*.dat ${OUTPUT_DIR}

for ppc in 1 2 4 8 16 32 64 128 256 512 1024
do
   sed -i "s/\(^[ ]\{4\}ppc =\) [0-9]*/\1 ${ppc}/" pic.py
   srun python pic.py
   mv indices1.dat ${OUTPUT_DIR}/indices1_ppc${ppc}.dat
   mv indices2.dat ${OUTPUT_DIR}/indices2_ppc${ppc}.dat
done

rm -f ./select_gpu
cd
rm -rf ${RUNKO_RUNDIR}
