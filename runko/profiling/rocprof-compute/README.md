# Profiling with rocprof-compute


See [the rocprof-compute docs](https://rocm.docs.amd.com/projects/rocprofiler-compute/en/docs-6.3.3/what-is-rocprof-compute.html) for help on using the tool.

## Install

The python dependencies of the profiler need to be installed manually.
See the `install_dependencies.sh` script, which should do just this.

## Build

Build the C++ project using `build.sh`.

## Run

Use `sbatch submit.sh` to run the tracing. Change the `ROCPROFCOMPUTE` env var inside the script to your liking.

## Analyze the results

### Without web ui

Use the `-k/--kernel 0` to choose the kernel for which
to show the data. You can correlate the id with the name with
`rocprof-compute analyze --list-stats -p /path/to/workloads/experiment_name/MI210/`.

Then, to analyze the workload for kernel id 0, run:
`rocprof-compute analyze --kernel 0 -p /path/to/workloads/experiment_name/MI210/`.

### With web ui

Any output files will be written to the `OUTPUT_DIR` directory.
See the [documentation](https://rocm.docs.amd.com/projects/rocprofiler-compute/en/docs-6.3.3/how-to/analyze/mode.html) of the tool on how to visualize/analyze the results.

Here's a quick step-by-step:

1. `ssh` to LUMI
2. cd to this directory
4. run `rocprof-compute analyze -p /path/to/workloads/experiment_name/MI210/ --gui`
5. Wait until you see something similar to
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

6. Start a new terminal
7. On the new terminal run `ssh -L 8050:uan01:8050 username@lumi.csc.fi -N` (replace uan01 with the login node you're running on).
8. Open web browser
9. Go to `localhost:8050`
