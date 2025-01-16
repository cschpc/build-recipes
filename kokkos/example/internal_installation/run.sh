#!/bin/bash -l
#SBATCH --job-name=kokkos_example   # Job name
#SBATCH --partition=standard-g  # partition name
#SBATCH --nodes=1               # Total number of nodes 
#SBATCH --ntasks-per-node=1     # 8 MPI ranks per node, 16 total (2x8)
#SBATCH --gpus-per-node=1       # Allocate one gpu per MPI rank
#SBATCH --time=00:01:00       # Run time (d-hh:mm:ss)
#SBATCH --account=project_462000007

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
#export MPICH_GPU_SUPPORT_ENABLED=1
OMP_PROC_BIND=spread
OMP_PLACES=threads

srun kokkos-example/v0.1.0.0/Release/bin/kokkos-example-cli
