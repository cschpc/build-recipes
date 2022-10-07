"""User provided customizations.

Here one changes the default arguments for compiling _gpaw.so (serial)
and gpaw-python (parallel).

Here are all the lists that can be modified:

* libraries
* library_dirs
* include_dirs
* extra_link_args
* extra_compile_args
* runtime_library_dirs
* extra_objects
* define_macros
* mpi_libraries
* mpi_library_dirs
* mpi_include_dirs
* mpi_runtime_library_dirs
* mpi_define_macros

To override use the form:

    libraries = ['somelib', 'otherlib']

To append use the form

    libraries += ['somelib', 'otherlib']
"""

parallel_python_interpreter = True

# compiler
compiler = os.environ['CC']
mpicompiler = 'mpicc'
mpilinker = 'mpicc'
extra_compile_args = ['-std=c99', '-O3', '-fopenmp', '-fopenmp-simd',
                      '-march=native', '-mtune=native', '-mavx2']
extra_link_args = ['-fopenmp']

#extra_link_args = ['-fno-lto']

# libz
libraries = ['z']

# libxc
library_dirs += [os.environ['LIBXCDIR'] + '/lib']
include_dirs += [os.environ['LIBXCDIR'] + '/include']
libraries += ['xc']

# MKL
# libraries += ['mkl_core', 'mkl_intel_lp64' ,'mkl_sequential']
libraries += os.environ['BLAS_LIBS'].split()

# use ScaLAPACK 
scalapack = True
if scalapack:
    libraries += os.environ['SCALAPACK_LIBS'].split()

fftw = True
if fftw:
    libraries += ['fftw3']

# ELPA
elpa = True
elpadir = os.environ['ELPADIR']
libraries += ['elpa_openmp']
library_dirs += ['{}/lib'.format(elpadir)]
include_dirs += ['{}/include/elpa_openmp-2021.05.001'.format(elpadir)]
extra_link_args += ['-Wl,-rpath={}/lib'.format(elpadir)]

# GPAW defines
define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]
define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]
define_macros += [("GPAW_ASYNC",1)]
define_macros += [("GPAW_MPI2",1)]

