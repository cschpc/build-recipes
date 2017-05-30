# load compile stack
source /opt/intel/compilers_and_libraries_2017.0.098/linux/mpi/bin64/mpivars.sh
source /opt/intel/compilers_and_libraries_2017.0.098/linux/bin/compilervars.sh intel64

# target
base=<BASE>

# set environment
export PYTHONHOME=$base/python-<PYTHON>
export PYTHONPATH=$base/python-<PYTHON>/lib
export PATH=$base/python-<PYTHON>/bin:$PATH
export LIBXCDIR=$base/libxc-<LIBXC>
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$base/libxc-<LIBXC>/lib
export GPAW_SETUP_PATH=$base/gpaw-setups-<SETUPS>
export PYTHONPATH=$base/ase-<ASE>/lib/python2.7/site-packages:$PYTHONPATH
export PATH=$base/ase-<ASE>/bin:$PATH
export PYTHONPATH=$base/gpaw-<GPAW>/lib/python:$PYTHONPATH
export PATH=$base/gpaw-<GPAW>/bin:$PATH

