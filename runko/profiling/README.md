# Profiling

## Installing dependencies

First install the dependencies with the `install_dependencies.sh` script.
This installs `viztracer` python package in addition to
the rest of the python dependencies for runko.
It also installs the dependencies for rocprofiler-compute for Rocm 6.4.4.

Run it on a compute node: `sbatch install_dependencies.sh`.

There is a scorep python package which can be used to profile python along with C++,
but the problem on LUMI is that the cray-clang compiler has a bug, and it cannot
instrument C++ at all, so it's quite useless.

## Build

Build the project on the compute node with `sbatch build.sh`.

## Run

Follow the READMEs in the individual directories for running instructions.
