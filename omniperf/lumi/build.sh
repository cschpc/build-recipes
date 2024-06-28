#!/bin/bash

[ $# -eq 4 ] || { 
    echo "Give four arguments:"
    echo "path to requirements.txt"
    echo "path to install dir"
    echo "path to post build script"
    echo "path to env.yaml"
    echo "For example:"
    echo "./build.sh requirements.txt /projappl/project_465001194/apps/omniperf post_build.sh env.yaml"
    exit 1
}

requirements=$1
prefix=$2
post_build=$3
env=$4

ml CrayEnv
ml lumi-container-wrapper
ml rocm/5.4.6
ml craype-accel-amd-gfx90a
ml craype-x86-trento

conda-containerize new -r $requirements --prefix $prefix --post $post_build -w 1.1.0/bin/omniperf $env
