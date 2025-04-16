#!/bin/bash
# source me when you want to use this python
export PYTHONHOME=<BASE>
export PYTHONPATH=$PYTHONHOME/lib
export PATH=$PYTHONHOME/bin:$PATH
export MANPATH=$PYTHONHOME/share/man:$MANPATH
export LD_LIBRARY_PATH=$PYTHONHOME/lib:$LD_LIBRARY_PATH

# Add the used libraries to path when using this python
lib_prefix=/appl/lumi/SW/LUMI-24.03/C/EB
gdbm=${lib_prefix}/gdbm/1.23-cpeCray-24.03
ffi=${lib_prefix}/libffi/3.4.4-cpeCray-24.03
sqlite=${lib_prefix}/SQLite/3.43.1-cpeCray-24.03

export LD_LIBRARY_PATH="${gdbm}/lib64:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${ffi}/lib64:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${sqlite}/lib64:${LD_LIBRARY_PATH}"

export OMP_NUM_THREADS=1

if [[ $# -gt 0 ]]
then
    export PYTHONUSERBASE=$PYTHONHOME/bundle/$1
elif [[ -e $PYTHONHOME/bundle/default ]]
then
    export PYTHONUSERBASE=$PYTHONHOME/bundle/default
fi
