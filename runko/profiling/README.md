# Profiling

## Installing dependencies

First install the dependencies with the `install_dependencies.sh` script.
This installs `viztracer` python package in addition to
the rest of the python dependencies for runko.
It also installs the dependencies for rocprofiler-compute for Rocm 6.4.4.

Run it on a compute node: `sbatch install_dependencies.sh`.

There is a scorep python package which can be used to profile python along with C++,
but the problem on LUMI is that the cray-clang compiler has a bug, and it cannot
instrument C++ at all, so it's quite useless. An option is to manually instrument
the desired C++ functions. For this, one should install Score-P e.g. with the
[EasyBuild recipes](https://lumi-supercomputer.github.io/LUMI-EasyBuild-docs/s/Score-P/),
install the 
[scorep module for python](https://github.com/score-p/scorep_binding_python),
instrument the functions, and use it to profile the whole stack.

## Build

Build the project on the compute node with `sbatch build.sh`.

## Run

Call `sbacth submit.sh the-experiment-name` to profile runko using one of the
defined tools. See the script for available experiments.

Below are some notes for each experiment.

### flamegraph

This experiment uses perf to sample runko. A flamegraph image is generated from the run.
For this, one should clone the [flamegraph scripts](https://github.com/brendangregg/FlameGraph)
used to generate the image from perf data, and set the environment variable `FGDIR`
to point to the root of that directory.

### viztracer

https://github.com/gaogaotiantian/viztracer

This experiment traces the python functions that are called through the `self._action(name, *vargs, **kwargs)`
in `method_wrapper.py`. By applying the patch in this directory, one can change the `method_wrapper` to include
the needed changes.

The patch was made againts commit `e6420fc37c3102baa34bd78b14671828ad24b6e8`.

To apply it, do `git apply path/to/this/method_wrapper_viztracer.patch` in the root of the runko directory.

`viztracer` needs to be installed for the experiment to work.

### rocprof

https://rocm.docs.amd.com/projects/rocprofiler-sdk/en/latest/how-to/using-rocprofv3.html

rocprof is used to generate a (GPU) trace of the application. See the docs above for info on how
to use the tool.

To view the generated trace(s), copy the generated `.pftrace` files to your laptop and open one of them on [ui.perfetto.dev](ui.perfetto.dev).
The files will be written to the `OUTPUT_DIR` directory.

### rocprof-compute

https://rocm.docs.amd.com/projects/rocprofiler-compute/en/latest/what-is-rocprof-compute.html

rocprof-compute is used to profile one or more GPU kernels. See the docs above for how to use
the tool.

The generated results will be found in the `OUTPUT_DIR` directory, under `workloads`.

#### Analyze the results

##### Without web ui

Use the `-k/--kernel 0` to choose the kernel for which
to show the data. You can correlate the id with the name with
`rocprof-compute analyze --list-stats -p /path/to/workloads/experiment_name/MI210/`.

Then, to analyze the workload for kernel id 0, run:
`rocprof-compute analyze --kernel 0 -p /path/to/workloads/experiment_name/MI210/`.

##### With web ui

Any output files will be written to the `OUTPUT_DIR` directory.
See the [documentation](https://rocm.docs.amd.com/projects/rocprofiler-compute/en/docs-6.3.3/how-to/analyze/mode.html) of the tool on how to visualize/analyze the results.

Here's a quick step-by-step:

1. `ssh` to LUMI
2. Load the correct modules, e.g. the ones used by the `submit.sh` script.
3. run `rocprof-compute analyze -p /path/to/workloads/experiment_name/MI210/ --gui`
4. Wait until you see something similar to
```bash
(venv) juhanala@uan01:/projappl/project_462001358/juhanala/runko> rocprof-compute analyze -p workloads/deposit/MI210/ --gui

                                 __                                       _
 _ __ ___   ___ _ __  _ __ ___  / _|       ___ ___  _ __ ___  _ __  _   _| |_ ___
| '__/ _ \ / __| '_ \| '__/ _ \| |_ _____ / __/ _ \| '_ ` _ \| '_ \| | | | __/ _ \
| | | (_) | (__| |_) | | | (_) |  _|_____| (_| (_) | | | | | | |_) | |_| | ||  __/
|_|  \___/ \___| .__/|_|  \___/|_|        \___\___/|_| |_| |_| .__/ \__,_|\__\___|
               |_|                                           |_|

INFO:root:Analysis mode = web_ui
   INFO Analysis mode = web_ui
INFO:root:[analysis] deriving rocprofiler-compute metrics...
   INFO [analysis] deriving rocprofiler-compute metrics...
Dash is running on http://uan01:8050/

INFO:dash.dash:Dash is running on http://uan01:8050/

   INFO Dash is running on http://uan01:8050/

 * Serving Flask app 'rocprof_compute_analyze.analysis_webui'
 * Debug mode: off
INFO:werkzeug:WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://uan01:8050
   INFO WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://uan01:8050
INFO:werkzeug:Press CTRL+C to quit
   INFO Press CTRL+C to quit

```

5. Start a new terminal on your laptop.
6. On the new terminal run `ssh -L 8050:uan01:8050 username@lumi.csc.fi -N` (replace uan01 with the login node you're running rocprof-compute on).
7. Open the web browser on your laptop.
8. Go to `localhost:8050`
