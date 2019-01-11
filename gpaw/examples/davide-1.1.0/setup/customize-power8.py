# Setup customisation for gpaw/cuda
import os

# compiler and linker
compiler = 'gcc'
mpicompiler = 'mpicc'
mpilinker = 'mpicc'
extra_compile_args = ['-std=c99', '-mcpu=power8']

# libraries
libraries = ['z']

# openblas
library_dirs += [os.environ['OPENBLAS_ROOT'] + '/lib']
include_dirs += [os.environ['OPENBLAS_ROOT'] + '/include']
libraries += ['openblas']

# scalapack
library_dirs += [os.environ['SCALAPACK_ROOT'] + '/lib']
libraries += ['scalapack']

# libxc
library_dirs += [os.environ['LIBXCDIR'] + '/lib']
include_dirs += [os.environ['LIBXCDIR'] + '/include']
libraries += ['xc']

# GPAW defines
define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]
define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]
define_macros += [("GPAW_ASYNC",1)]
define_macros += [("GPAW_MPI2",1)]
define_macros += [('GPAW_CUDA', '1')]

# ScaLAPACK
scalapack = True

# HDF5
hdf5 = False

