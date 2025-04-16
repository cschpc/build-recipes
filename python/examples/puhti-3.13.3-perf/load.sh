#!/bin/bash
# source me when you want to use this python
export PYTHONHOME=<BASE>
export PYTHONPATH=$PYTHONHOME/lib
export PATH=$PYTHONHOME/bin:$PATH
export MANPATH=$PYTHONHOME/share/man:$MANPATH
export LD_LIBRARY_PATH=$PYTHONHOME/lib:$LD_LIBRARY_PATH

# Add the used libraries to path when using this python
lib_prefix=/appl/spack/v018/install-tree/gcc-11.3.0

export LD_LIBRARY_PATH="${lib_prefix}/gdbm-1.19-bwdskf/lib:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${lib_prefix}/libffi-3.4.2-l3lpph/lib64:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${lib_prefix}/sqlite-3.38.5-mu7dxs/lib:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${lib_prefix}/tcl-8.6.12-3ycyko/lib:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${lib_prefix}/tk-8.6.11-6zbavi/lib:${LD_LIBRARY_PATH}"

export OMP_NUM_THREADS=1

if [[ $# -gt 0 ]]
then
    export PYTHONUSERBASE=$PYTHONHOME/bundle/$1
elif [[ -e $PYTHONHOME/bundle/default ]]
then
    export PYTHONUSERBASE=$PYTHONHOME/bundle/default
fi
