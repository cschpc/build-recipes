# Custom GPAW setup for Sisu (Cray XC40)
import os

# compiler and linker
compiler = './gcc.py'
mpicompiler = './gcc.py'
mpilinker = 'cc'
extra_compile_args = ['-std=c99', '-O3', '-fopenmp-simd']

# libraries
libraries = ['z']

# libxc
library_dirs += [os.environ['LIBXCDIR'] + '/lib']
include_dirs += [os.environ['LIBXCDIR'] + '/include']
libraries += ['xc']

# ScaLAPACK and HDF5
scalapack = True
hdf5 = True

# GPAW defines
define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]
define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]
define_macros += [("GPAW_ASYNC",1)]
define_macros += [("GPAW_MPI2",1)]

