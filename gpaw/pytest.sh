#!/bin/bash

host=$(hostname)

if [[ $host == puhti* ]]; then
    sbatch_args="-p small --mem-per-cpu=4G"
elif [[ $host == mahti* ]]; then
    sbatch_args="-p medium --mem=0"
fi

# Test target
tgt=gpaw_test_3

echo "--------------------------------------------------------------------------------"
echo "- Load GPAW module"
echo "--------------------------------------------------------------------------------"
module purge
module use $PWD/$tgt/modulefiles/
module load my-gpaw
gpaw info


echo "--------------------------------------------------------------------------------"
echo "- Install pytest"
echo "--------------------------------------------------------------------------------"
export PYTHONUSERBASE=$PWD/tmp/${tgt}_pythonuserbase
export PATH=$PATH:$PYTHONUSERBASE/bin
if [ -d "$PYTHONUSERBASE/bin" ]; then
    echo "exists; skipping"
else
    python3 -m pip install --user pytest
fi


echo "--------------------------------------------------------------------------------"
echo "- Set paths"
echo "--------------------------------------------------------------------------------"
test_dir=$(gpaw info | grep '| gpaw' | awk '{print $3}')/test
echo "GPAW test files: $test_dir"
root_dir=$PWD/tmp/${tgt}_pytest_runs
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
    srun -J $name -t 01:00:00 -N 1 -n 1 --cpus-per-task=1 $sbatch_args pytest -v --disable-pytest-warnings -o cache_dir=$cache_dir test/test_generate_gpwfiles.py | tee slurm.out
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
    sbatch -J $name -o slurm.out -t 04:00:00 -N 1 -n $n --cpus-per-task=1 $sbatch_args --wrap="gpaw info; srun $cmd --disable-pytest-warnings -o cache_dir=$cache_dir test/"
    popd
}


for n in 1 2 4 8; do
    submit_job "gpaw_pytest_n$n" "$n" "pytest -v"
    submit_job "gpaw_pytest_n$n-gp" "$n" "gpaw-python -m pytest -v"
done

