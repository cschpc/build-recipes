# Compute and output particle cell indices

## Patch

Apply the patch `current.patch` with `git apply /path/to/current.patch`
in runko repository directory (not here).
The patch is based on commit `25cebc59dc2ab144f57c6e714781e9c15bf97a9d`.

## Build

Build the C++ project without instrumentation.

## Run

Use `sbatch submit.sh` to run the experiment.

By default it runs the `pic.py` script in this directory.

The run produces two index files per time step for each `ppc`
value used in `submit.sh`.

## Visualize the data

How large a box is required by the particle indices `i1` and `i2`
for `N` consecutive particles is computed by the script `box_sizes.py`
and the distribution of these box sizes is plotted in histograms.

The point of this is to visualize and find out how large an `N`
can be used for different values of `ppc` such that the
required box is as small as possible.
