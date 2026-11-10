# Profiling with Score-P

## Preprocessing

Score-P does not understand the `.c++` extension used by runko.
To instrument with Score-P, the extensions have to be changed
to a more common extension, e.g. `.cpp`.

### TL;DR

Apply [these](./corgi.patch) [patches](./runko.patch)
in the runko repository to rename the desired files
(patch based on commit 25cebc59dc2ab144f57c6e714781e9c15bf97a9d)
```bash
git -C external/corgi/ apply ../../profiling/scorep/corgi.patch
git apply profiling/scorep/runko.patch
```

### Manually

It takes some manual fiddling, but here are helpful scripts.

Run this in the runko repository to get a list of source files that
refer to `.c++`:
```bash
grep -rI "\.c++" | awk -F: '{print $1}' | sort | uniq
```
most of them are tests/prototypes/other and not of interest.

These commands rename the `.c++` files of interest under [src](../../src)
and [external](../../external/).
The files under `src` are changed based on the extension,
and thus take new files in to account.
The libraries under `external` are mostly header-only,
with mostly tests/prototypes with a `.c++` extension,
so the file(s) to change are hard coded here.
```
# src
sed -i 's/\.c++/\.cpp/' src/CMakeLists.txt
for file in $(find src/ -name "*.c++"); do mv $file "${file:0:-3}cpp"; done

# external/
sed -i 's/\.c++/\.cpp/' external/corgi/pycorgi/CMakeLists.txt
mv external/corgi/pycorgi/pycorgi.c++ external/corgi/pycorgi/pycorgi.cpp
```

## Installing Score-P

Score-P and the python package `scorep` need to be installed.
See the scripts [install_scorep.sh](../install_scorep.sh) and
[install_dependencies.sh](../install_dependencies.sh).

## Instrumenting

The script [build_instrumented.sh](../build_instrumented.sh)
can be used to build runko with instrumentation.

## Running

Use the [submit.sh](./submit.sh) script to run: `sbatch submit.sh`.
Read the
[Score-P](https://perftools.pages.jsc.fz-juelich.de/cicd/scorep/tags/latest/html/workflow.html)
and
[scorep python package](https://github.com/score-p/scorep_binding_python)
documentation for more info on how to use Score-P.
