#!/bin/bash

version=${1:-24.1.0-omp}


echo "--------------------------------------------------------------------------------"
echo "- Load GPAW module"
echo "--------------------------------------------------------------------------------"
#module purge
module use $HOME/tmp/test_gpaw_1/modulefiles/
module load gpaw/$version
gpaw info


echo "--------------------------------------------------------------------------------"
echo "- Install pytest"
echo "--------------------------------------------------------------------------------"
export PYTHONUSERBASE=$HOME/tmp/test_gpaw_pytest
export PATH=$PATH:$PYTHONUSERBASE/bin
python3 -m pip install --user pytest


echo "--------------------------------------------------------------------------------"
echo "- Set paths"
echo "--------------------------------------------------------------------------------"
test_dir=$(gpaw info | grep '| gpaw' | awk '{print $3}')/test
echo "GPAW test files: $test_dir"
root_dir=$HOME/tmp/test_gpaw_run_pytest
echo "root directory for tests: $root_dir"


echo "--------------------------------------------------------------------------------"
echo "- Generate gpwfiles"
echo "--------------------------------------------------------------------------------"
name=gpaw_pytest_gpw
run_dir=$root_dir/$name
cache_dir=$run_dir/pytest_cache
gpw_files=$cache_dir/d/gpaw_test_gpwfiles
echo "gpw files: $gpw_files"
if [ -d "$gpw_files" ]; then
    echo "exists; skipping"
else
    echo "generate"
    rm -rf $run_dir
    mkdir -p $run_dir
    pushd $run_dir
    echo "run dir: $run_dir"
    cp -r $test_dir ./
    srun -J $name -t 01:00:00 -p medium -N 1 -n 1 --cpus-per-task=1 --mem=0 pytest -v -o cache_dir=$cache_dir test/test_generate_gpwfiles.py | tee slurm.out
    popd
fi


echo "--------------------------------------------------------------------------------"
echo "- Submit tests"
echo "--------------------------------------------------------------------------------"

function submit_job {
    name="$1"
    n="$2"
    cmd="$3"
    run_dir=$root_dir/$name
    cache_dir=$run_dir/pytest_cache

    rm -rf $run_dir
    mkdir -p $run_dir
    pushd $run_dir
    echo "run dir: $run_dir"
    cp -r $test_dir ./
    mkdir -p $cache_dir/d
    cp -r $gpw_files $cache_dir/d/
    sbatch -J $name -o slurm.out -t 04:00:00 -p medium -N 1 -n $n --cpus-per-task=1 --mem=0 --wrap="gpaw info; srun $cmd -o cache_dir=$cache_dir test/"
    popd
}


for n in 1 2 4 8; do
    submit_job "gpaw_pytest_n$n" "$n" "pytest -v"
    submit_job "gpaw_pytest_n$n-gp" "$n" "gpaw-python -m pytest -v"
done


echo "--------------------------------------------------------------------------------"
echo "- Load new ASE"
echo "--------------------------------------------------------------------------------"
module load ase/.master-2023-09-28-53987ebbdf
gpaw info


echo "--------------------------------------------------------------------------------"
echo "- Submit tests with new ASE"
echo "--------------------------------------------------------------------------------"

for n in 1 2 4 8; do
    submit_job "gpaw_pytest_n$n-newase" "$n" "pytest -v"
    submit_job "gpaw_pytest_n$n-gp-newase" "$n" "gpaw-python -m pytest -v"
done
