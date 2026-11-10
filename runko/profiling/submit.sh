#!/bin/bash -l

#SBATCH --account=project_462001358
#SBATCH --partition=standard-g
#SBATCH --job-name=runko-profile-run
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --gpus-per-node=8
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=0-03:00:00       # Run time (d-hh:mm:ss)

set -e

prepare_directories() {
    if [[ "x${RUNKO_PROFILING_EXPERIMENT}x" == "xx" ]]
    then
        echo "RUNKO_PROFILING_EXPERIMENT has not been set"
        exit 1
    fi

    RUNKO_RUNDIR=/tmp/$USER/$RUNKO_PROFILING_EXPERIMENT
    mkdir -p ${RUNKO_RUNDIR}

    cp ${RUNKODIR}/projects/pic-turbulence/pic.py ${RUNKO_RUNDIR}/pic.py
    cp ${RUNKODIR}/projects/pic-turbulence/*.ini ${RUNKO_RUNDIR}/

    cat << EOF > ${RUNKO_RUNDIR}/select_gpu
#!/bin/bash
export ROCR_VISIBLE_DEVICES=\$SLURM_LOCALID

exec \$*
EOF

    chmod +x ${RUNKO_RUNDIR}/select_gpu
}

prepare_environment() {
    ml LUMI/25.09
    ml partition/G
    ml PrgEnv-cray
    ml rocm/6.4.4
    ml craype-accel-amd-gfx90a
    ml cray-mpich/9.0.1
    ml craype-network-ofi
    ml buildtools
    ml cray-python
    ml Boost/1.90.0-cpeCray-25.09
    ml lumi-CrayPath

    source ${RUNKODIR}/venv/bin/activate

    # Set LD_LIBRARY_PATH so python's import finds all the libraries
    local deps_base=${RUNKODIR}/build/editable-RelWithDebInfo-cp311-cp311-linux_x86_64

    local lib_paths=${deps_base}/external/tyvi/src
    lib_paths=${deps_base}/_deps/pika-build/lib:${lib_paths}
    lib_paths=${deps_base}/_deps/spdlog-build:${lib_paths}
    lib_paths=${deps_base}/_deps/fmt-build:${lib_paths}

    export LD_LIBRARY_PATH=${lib_paths}:${LD_LIBRARY_PATH}

    CPU_BIND="mask_cpu:7e000000000000,7e00000000000000"
    CPU_BIND="${CPU_BIND},7e0000,7e000000"
    CPU_BIND="${CPU_BIND},7e,7e00"
    CPU_BIND="${CPU_BIND},7e00000000,7e0000000000"

    export OMP_NUM_THREADS=6
    export MPICH_GPU_SUPPORT_ENABLED=1
    export MPICH_GPU_IPC_ENABLED=0
}

setup() {
    RUNKO_PROFILING_EXPERIMENT=$1
    if [[ "x${2}x" == "xx" ]]
    then
        RUN_NAME=$(date +%Y-%m-%dT%T)
    else
        RUN_NAME=$2
    fi

    echo "Running runko profiling experiment \"$1\""
    prepare_directories
    prepare_environment
    old_pwd=${PWD}
    cd ${RUNKO_RUNDIR}
}

change_lap_count() {
    sed -E -i "s/(^[ ]{4}conf.n_laps = )(.*)/\1 $1/" pic.py
}

copy_output_and_cleanup() {
    rm select_gpu
    cd ${old_pwd}

    if [[ -d ${RUNKO_RUNDIR} ]]
    then
        OUTPUT_DIR=/scratch/project_462001358/$USER/runko_profiles/${SLURM_JOB_ID}-${RUNKO_PROFILING_EXPERIMENT}-${RUN_NAME}
        echo "Writing output to ${OUTPUT_DIR}"
        mkdir -p $OUTPUT_DIR
        cp -r ${RUNKO_RUNDIR}/* ${OUTPUT_DIR}/
        rm -rf ${RUNKO_RUNDIR}
    fi
}

if [[ ! -d ${RUNKODIR} ]]
then
    echo "Set the variable RUNKODIR to point to the runko repository directory"
    exit 1
fi

if [[ $# -lt 1 ]]
then
    echo "Usage: \"sbatch $0 experiment [run-name]\", where run-name is an optional string that's appended to the output directory name"
    exit 1
fi

case $1 in
    "flamegraph")
        if [ ! -d ${FGDIR} ]
        then
            echo "Set the variable FGDIR to point to the FlameGraph repository directory"
            exit 1
        fi

        setup $1 $2
        change_lap_count 100

        srun \
            --cpu-bind=${CPU_BIND} \
            ./select_gpu \
            perf record \
                -F 1997 \
                -g \
                -o perf-${SLURM_LOCALID}.data \
            python pic.py && \
            perf script \
                -i perf-${SLURM_LOCALID}.data | \
            ${FGDIR}/stackcollapse-perf.pl | \
            ${FGDIR}/flamegraph.pl > flamegraph-${SLURM_LOCALID}.svg
        ;;
    "viztracer")
        setup $1 $2
        change_lap_count 100

        srun \
            --cpu-bind=${CPU_BIND} \
            ./select_gpu \
            python -m viztracer \
                --pid_suffix \
                --log_sparse \
                pic.py

        viztracer --combine result*.json --output_file combined.json
        rm result*.json
        ;;
    "rocprof")
        setup $1 $2
        change_lap_count 100

        ROCPROFV3="rocprofv3"
        ROCPROFV3="${ROCPROFV3} --sys-trace"
        #ROCPROFV3="${ROCPROFV3} --collection-period 60:1:5"
        ROCPROFV3="${ROCPROFV3} --output-format pftrace"
        ROCPROFV3="${ROCPROFV3} --output-file %launch_time%-%hostname%-%pid%-%rank%.pftrace"
        ROCPROFV3="${ROCPROFV3} --"

        srun \
            --cpu-bind=${CPU_BIND} \
            ./select_gpu \
            ${ROCPROFV3} python pic.py
        ;;
    "rocprof-compute")
        setup $1 $2
        change_lap_count 20

        ROCPROFCOMPUTE="rocprof-compute"
        ROCPROFCOMPUTE="${ROCPROFCOMPUTE} profile"
        ROCPROFCOMPUTE="${ROCPROFCOMPUTE} --name runko-compute-profile"
        ROCPROFCOMPUTE="${ROCPROFCOMPUTE} --"

        srun \
            --cpu-bind=${CPU_BIND} \
            ./select_gpu \
            ${ROCPROFCOMPUTE} python pic.py
        ;;
    *)
        echo "Invalid argument \"$1\""
        exit 1
        ;;
esac

copy_output_and_cleanup
