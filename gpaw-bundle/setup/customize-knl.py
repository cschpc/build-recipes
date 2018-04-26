# Custom GPAW setup for Intel MICs (KNL)
import os

# use Intel compiler and MPI
mpicompiler = 'mpiicc'
mpilinker = 'mpiicc'
compiler = 'mpiicc'

# use MKL
mklroot = os.environ['MKLROOT']
library_dirs += [mklroot + '/lib/intel64/']
libraries = ['mkl_intel_lp64', 'mkl_intel_thread', 'mkl_core',
             'mkl_lapack95_lp64', 'mkl_scalapack_lp64',
             'mkl_blacs_intelmpi_lp64', 'pthread', 'iomp5']

# libxc
library_dirs += [os.environ['LIBXCDIR'] + '/lib']
include_dirs += [os.environ['LIBXCDIR'] + '/include']
libraries += ['xc']

# compiler settings for Intel compiler
extra_compile_args = []
extra_compile_args += ['-qopt-report=5', '-g'] # debug?
extra_compile_args += ['-qopenmp-simd'] # SIMD
extra_compile_args += ['-O3', '-xMIC-AVX512']
extra_compile_args += ['-no-prec-div', '-std=c99', '-fPIC', '-qopenmp']

# GPAW defines
define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]
define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]
define_macros += [("GPAW_ASYNC",1)]
define_macros += [("GPAW_MPI2",1)]

# use ScaLAPACK
scalapack = True

