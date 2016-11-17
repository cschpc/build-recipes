#User provided customizations for the gpaw setup
import os

# compiler
compiler = './gcc.py'
mpicompiler = './gcc.py'
mpilinker = 'cc'
extra_compile_args = ['-std=c99']

# libz
libraries = ['z']

# libxc
library_dirs += [os.environ['LIBXCDIR'] + '/lib']
include_dirs += [os.environ['LIBXCDIR'] + '/include']
libraries += ['xc']

# libvdwxc
libvdwxc = True
path = '/appl/nano/libvdwxc/git-2420ab74'
extra_link_args += ['-Wl,-rpath=%s/lib' % path]
library_dirs += ['%s/lib' % path]
include_dirs += ['%s/include' % path]
libraries += ['vdwxc']

# use ScaLAPACK and HDF5
scalapack = True
hdf5 = True

# GPAW defines
define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]
define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]
define_macros += [("GPAW_ASYNC",1)]
define_macros += [("GPAW_MPI2",1)]

