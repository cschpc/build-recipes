parallel_python_interpreter = True

mpi = True
compiler = 'mpicc'
libraries = []
library_dirs = []
include_dirs = []
extra_compile_args = [
    '-O3',
    '-march=native',
    '-mtune=native',
    '-fopenmp',  # implies -fopenmp-simd
    ]
extra_link_args = ['-fopenmp']

# MKL
libraries += ['mkl_core', 'mkl_gnu_thread', 'mkl_intel_lp64']

# scalapack
scalapack = True
libraries += ['mkl_scalapack_lp64', 'mkl_blacs_openmpi_lp64']

# fftw
fftw = True
libraries += ['fftw3']

# libxc
libraries += ['xc']
dpath = '/appl/spack/v018/install-tree/gcc-11.3.0/libxc-5.1.7-4aszho'
include_dirs += [f'{dpath}/include']
library_dirs += [f'{dpath}/lib']
extra_link_args += [f'-Wl,-rpath,{dpath}/lib']

define_macros += [('GPAW_ASYNC', 1)]
define_macros += [('GPAW_MPI2', 1)]
