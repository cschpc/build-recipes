# Custom GPAW setup for Intel MICs (KNL)
import os

# use Intel compiler and MPI
#compiler = 'mpiicc'
#mpicompiler = 'mpiicc'
#mpilinker = 'mpiicc'
compiler = 'cc'
mpicompiler = 'cc'
mpilinker = 'cc'

# use MKL
mklroot = os.environ['MKLROOT']
library_dirs += [mklroot + '/lib/intel64/']
libraries = ['mkl_intel_lp64', 'mkl_intel_thread', 'mkl_core',
             'mkl_lapack95_lp64', 'mkl_scalapack_lp64',
             'mkl_blacs_intelmpi_lp64', 'pthread', 'iomp5']

# numpy
#include_dirs += [os.environ['PYTHONHOME'] \
#        + 'lib/python2.7/site-packages/numpy/core/include']

# libxc
library_dirs += [os.environ['LIBXCDIR'] + '/lib']
include_dirs += [os.environ['LIBXCDIR'] + '/include']
libraries += ['xc']

# compiler settings for Intel compiler
#extra_compile_args = ['-xMIC-AVX512', '-O3']
extra_compile_args = ['-O3']
extra_compile_args += ['-no-prec-div', '-std=c99', '-fPIC', '-qopenmp']

# GPAW defines
define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]
define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]
define_macros += [("GPAW_ASYNC",1)]
define_macros += [("GPAW_MPI2",1)]

# use ScaLAPACK
scalapack = True

