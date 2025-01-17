#!/bin/bash -l
#SBATCH --job-name=kokkos_example
#SBATCH --partition=gputest
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=128
#SBATCH --gres=gpu:a100:1
#SBATCH --time=00:01:00
#SBATCH --account=project_2002078

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_PROC_BIND=spread
export OMP_PLACES=threads

srun kokkos-example/v0.1.0.0/Release/bin/kokkos-example-cli
