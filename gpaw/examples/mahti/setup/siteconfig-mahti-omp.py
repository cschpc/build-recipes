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
    '-mavx2',
    '-fopenmp',  # implies -fopenmp-simd
    ]
extra_link_args = ['-fopenmp']

# blas
libraries += ['openblas']

# scalapack
scalapack = True
libraries += ['scalapack']
# fftw
fftw = True
libraries += ['fftw3']

# libxc
libraries += ['xc']
dpath = '/appl/spack/v017/install-tree/gcc-11.2.0/libxc-5.1.5-oa6ihp'
include_dirs += [f'{dpath}/include']
library_dirs += [f'{dpath}/lib']
extra_link_args += [f'-Wl,-rpath,{dpath}/lib']

# libvdwxc
libvdwxc = True
libraries += ['vdwxc']
# Not available in gcc/11.2.0 tree! Must take from gcc/13.1.0. Not ideal, but works
dpath = '/appl/spack/v020/install-tree/gcc-13.1.0/libvdwxc-0.4.0-5vlzlb/'
include_dirs += [f'{dpath}/include']
library_dirs += [f'{dpath}/lib']
extra_link_args += [f'-Wl,-rpath,{dpath}/lib']

define_macros += [('GPAW_ASYNC', 1)]
define_macros += [('GPAW_MPI2', 1)]
