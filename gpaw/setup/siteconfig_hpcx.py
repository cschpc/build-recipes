# Custom GPAW setup Puhti
import os

parallel_python_interpreter = True
# parallel_python_interpreter = False

# compiler
compiler = './gcc.py'
mpicompiler = './gcc.py'
mpilinker = 'mpicc'
extra_compile_args = ['-std=c99', '-O3', '-fopenmp-simd']
#extra_link_args = ['-fno-lto']

# libz
libraries = ['z']

# libxc
library_dirs += [os.environ['LIBXCDIR'] + '/lib']
include_dirs += [os.environ['LIBXCDIR'] + '/include']
libraries += ['xc']

# MKL
mklroot = os.environ['MKLROOT']
libraries += ['mkl_core', 'mkl_intel_lp64' ,'mkl_sequential']

# use ScaLAPACK and HDF5
scalapack = True
if scalapack:
    libraries += ['mkl_scalapack_lp64', 'mkl_blacs_openmpi_lp64']
# hdf5 = True

# GPAW defines
define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]
define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]
define_macros += [("GPAW_ASYNC",1)]
define_macros += [("GPAW_MPI2",1)]

