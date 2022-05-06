# Custom GPAW setup for Mahti (Bull Sequana XH2000)
import os
parallel_python_interpreter = True

# compiler and linker
compiler = os.environ['CC']
mpicompiler = 'mpicc'
mpilinker = 'mpicc'
extra_compile_args = ['-std=c99', '-O3', '-fopenmp-simd', '-march=native',
                      '-mtune=native', '-mavx2']

# libraries
libraries = ['z']

# libxc
library_dirs += [os.environ['LIBXCDIR'] + '/lib']
include_dirs += [os.environ['LIBXCDIR'] + '/include']
libraries += ['xc']

# MKL
libraries += os.environ['BLAS_LIBS'].split()

# ScaLAPACK
scalapack = True
if scalapack:
    libraries += os.environ['SCALAPACK_LIBS'].split()

# GPAW defines
define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]
define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]
define_macros += [("GPAW_ASYNC",1)]
define_macros += [("GPAW_MPI2",1)]

