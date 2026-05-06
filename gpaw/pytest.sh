#!/bin/bash

# Test target
tgt=gpaw_test_3

echo "--------------------------------------------------------------------------------"
echo "- Load GPAW module"
echo "--------------------------------------------------------------------------------"
module purge
module use $PWD/$tgt/modulefiles/
module load my-gpaw

module list

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
# should point to site-packages/gpaw/test of your new test install
test_dir=$(pip show gpaw | grep 'Location' | awk '{print $2}')/gpaw/test
echo "GPAW test files: $test_dir"
root_dir=$PWD/tmp/${tgt}_pytest_runs
echo "root directory for tests: $root_dir"


echo "--------------------------------------------------------------------------------"
echo "- Generate gpwfiles"
echo "--------------------------------------------------------------------------------"
name=gpaw_pytest_gpw
run_dir=$root_dir/$name
cache_dir=$run_dir/pytest_cache
tmp_dir=$run_dir/pytest_tmp
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
    srun -J $name -t 01:00:00 -N 1 -n 1 --cpus-per-task=1 $sbatch_args pytest -v --disable-pytest-warnings -o cache_dir=$cache_dir --basetemp=$tmp_dir test/test_generate_gpwfiles.py | tee slurm.out
    popd
fi


echo "--------------------------------------------------------------------------------"
echo "- Submit tests"
echo "--------------------------------------------------------------------------------"

function submit_job {
    name="$1"
    n="$2"
    cmd="$3"
    # ??? FIXME: Generates very long dir names
    tests="${4:-test/}"
    run_name="${name}_${tests}"
    run_name="${run_name// /_}"
    run_name="${run_name//=/_}"
    run_name="${run_name//\//.}"

    run_dir=$root_dir/$run_name
    cache_dir=$run_dir/pytest_cache
    tmp_dir=$run_dir/pytest_tmp

    # Hack around https://gitlab.com/gpaw/gpaw/-/issues/1441: some tests use
    # subprocesses and fail depending on MPI configuration. They are all
    # serial tests, so we can just run them without srun
    sbatch_args="--mem-per-cpu=4G"
    srun="srun"
    if [[ $n -eq 1 ]]; then
        sbatch_args="--mem-per-cpu=8G"
        srun=""
    fi

    rm -rf $run_dir
    mkdir -p $run_dir
    pushd $run_dir
    echo "run dir: $run_dir"
    ln -s $(readlink -f $test_dir) ./
    mkdir -p $cache_dir/d
    ln -s $(readlink -f $gpw_files) $cache_dir/d/
    sbatch -J $name -o slurm.out -t 04:00:00 -N 1 -n $n --cpus-per-task=1 -p small $sbatch_args --wrap="gpaw info; $srun $cmd --disable-pytest-warnings -o cache_dir=$cache_dir --basetemp=$tmp_dir $tests; rm -rf $tmp_dir"
    popd
}


# Run tests. Version 25.7 had some issues that we didn't manage to fix with patches:
#   1. OOM in test_coulomb.py (and occasionally in some other tests too)
#   2. Van der Waals tests (libvdwxc) fail if ran in the same run with other tests
# So here we skip the OOM test, and run VdW tests in a separate run.
for n in 1 2 4 8; do
    tests="--ignore=test/response/test_coulomb.py --ignore=test/vdw/ test/"
    submit_job "gpaw_pytest_n$n" "$n" "pytest -vs" "$tests"
    submit_job "gpaw_pytest_n$n-gp" "$n" "gpaw-python -m pytest -vs" "$tests"

    tests="test/vdw/"
    submit_job "gpaw_pytest_n$n" "$n" "pytest -vs" "$tests"
    submit_job "gpaw_pytest_n$n-gp" "$n" "gpaw-python -m pytest -vs" "$tests"
    # TODO: some tests are triggered only with export GPAW_NEW=1
done
