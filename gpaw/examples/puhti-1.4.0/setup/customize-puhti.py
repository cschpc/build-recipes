# Custom GPAW setup for Puhti (Bull Sequana X1000)
import os

# compiler and linker
compiler = './gcc.py'
mpicompiler = './gcc.py'
mpilinker = 'mpicc'
extra_compile_args = ['-std=c99', '-O3', '-fopenmp-simd']

# libraries
libraries = ['z']

# libxc
library_dirs += [os.environ['LIBXCDIR'] + '/lib']
include_dirs += [os.environ['LIBXCDIR'] + '/include']
libraries += ['xc']

# MKL
libraries += ['mkl_intel_lp64' ,'mkl_sequential' ,'mkl_core']
mpi_libraries += ['mkl_scalapack_lp64', 'mkl_blacs_intelmpi_lp64']

# ScaLAPACK and HDF5
scalapack = True
hdf5 = True

# GPAW defines
define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]
define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]
define_macros += [("GPAW_ASYNC",1)]
define_macros += [("GPAW_MPI2",1)]

