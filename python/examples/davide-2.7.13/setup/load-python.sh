#!/bin/bash
export PYTHONHOME=<BASE>
export PYTHONPATH=$PYTHONHOME/lib
export PATH=$PYTHONHOME/bin:$PATH
export MANPATH=$PYTHONHOME/share/man:$MANPATH
export LD_LIBRARY_PATH=$PYTHONHOME/lib:$LD_LIBRARY_PATH

if [[ $# -gt 0 ]]
then
    export PYTHONUSERBASE=$PYTHONHOME/bundle/$1
    export PATH=$PYTHONUSERBASE/bin:$PATH
    export LD_LIBRARY_PATH=$PYTHONUSERBASE/lib:$LD_LIBRARY_PATH
elif [[ -e $PYTHONHOME/bundle/default ]]
then
    export PYTHONUSERBASE=$PYTHONHOME/bundle/default
    export PATH=$PYTHONUSERBASE/bin:$PATH
    export LD_LIBRARY_PATH=$PYTHONUSERBASE/lib:$LD_LIBRARY_PATH
fi
if [[ -e $PYTHONUSERBASE/include/xc.h ]]
then
    export LIBXCDIR=$PYTHONUSERBASE
fi
