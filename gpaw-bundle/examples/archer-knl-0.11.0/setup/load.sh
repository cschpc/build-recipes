base=<BASE>
module swap PrgEnv-cray PrgEnv-intel/6.0.3
export PYTHONHOME=$base/python-2.7.10
export PYTHONPATH=$base/python-2.7.10/lib
export PATH=$base/python-2.7.10/bin:$PATH
export PYTHONPATH=$base/ase-3.9.1/lib:$PYTHONPATH
export PATH=$base/ase-3.9.1/bin:$PATH
export LIBXCDIR=$base/libxc-2.1.2
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$base/libxc-2.1.2/lib
export PYTHONPATH=$base/cython-0.23:$PYTHONPATH
export PATH=$base/cython-0.23/bin:$PATH
export GPAW_SETUP_PATH=$base/gpaw-setups-0.9.11271
export PATH=$base/gpaw-<GPAW>/bin:$PATH
export PYTHONPATH=$base/gpaw-<GPAW>/lib/python:$PYTHONPATH
export GPAW_PYTHON=$base/gpaw-<GPAW>/bin/gpaw-python
