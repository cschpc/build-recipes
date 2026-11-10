# Profiling with rocprofv3

See [the rocprofv3 docs](https://rocm.docs.amd.com/projects/rocprofiler-sdk/en/docs-6.4.3/index.html) for help on using the tool.

## Install

No extra dependencies need to be installed.

## Build

Build the C++ project without instrumentation.

## Run

Use `sbatch submit.sh` to run the tracing. Change the `ROCPROFV3` env var inside the script to your liking.

By default it runs the `pic.py` script in this directory.

## View the trace

Copy the generated `.pftrace` files to your laptop and open one of them on [ui.perfetto.dev](ui.perfetto.dev).
The files will be written to the `OUTPUT_DIR` directory.
