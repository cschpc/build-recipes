# Contents

This directory contains files for building runko inside a docker container
locally on a laptop. It also contains a profiling directory, which
contains scripts and documentation for profiling runko on LUMI with different tools.

The files directly in this directory are for building runko locally on a laptop:

- `Dockerfile` installs the dependencies, see comments within.
- `runs.sh` is a script to either enter bash inside the container or
  to run a single command inside it.
- `build_in_container.sh` uses `run.sh` to call cmake and build runko.
  One can e.g. `ln -s /path/to/build_in_container.sh build.sh` inside the runko repo
  and then run `./build.sh` to build runko locally.

The files under `profiling` are meant for profiling runko and processing/plotting
profiling data. Each subdirectory contains instructions for using the scripts.
