####################################################################
#  make include file.                                              #
####################################################################
#
SHELL = /bin/sh

# ----------------------------------------------------------------------
# - gpaw-cuda Directory Structure / gpaw-cuda library --------------------
# ----------------------------------------------------------------------
#
TOPdir        = .
INCdir        = $(TOPdir)
PYTHONINCdir ?= $(PYTHONHOME)/include/python3.7m/
PYTHONLIBdir ?= $(PYTHONHOME)/lib/
NUMPYINCdir  ?= $(shell python3 -c "import numpy; print(numpy.get_include())")
MPIINCdir    ?= $(MPICH_INSTALL_ROOT)/include
LIBdir        = $(TOPdir)
CUGPAWLIB     = $(LIBdir)/libgpaw-cuda.a

#
# ----------------------------------------------------------------------
# - NVIDIA CUDA includes / libraries / specifics -----------------------
# ----------------------------------------------------------------------
CUDAINCdir    = $(CUDADIR)/include
CUDALIBdir    = $(CUDADIR)/lib64
CUDA_OPTS     =

#
# ----------------------------------------------------------------------
# - gpaw-cuda includes / libraries / specifics -------------------------------
# ----------------------------------------------------------------------
#

CUGPAW_INCLUDES =  -I$(INCdir) -I$(CUDAINCdir) -I$(MPIINCdir) -I$(NUMPYINCdir)  -I$(PYTHONINCdir)
CUGPAW_OPTS     = -DPARALLEL=1 -DGPAW_CUDA=1

#
# ----------------------------------------------------------------------
#

CUGPAW_DEFS     = $(CUGPAW_OPTS) $(CUDA_OPTS)  $(CUGPAW_INCLUDES)

#
# ----------------------------------------------------------------------
# - Compilers / linkers - Optimization flags ---------------------------
# ----------------------------------------------------------------------
CC           = gcc
CCNOOPT      = $(CUGPAW_DEFS)
CCFLAGS      = $(CUGPAW_DEFS) -g -fPIC -std=c99 -m64 -O3 -mavx512f

NVCC           = nvcc
NVCCFLAGS      = $(CUGPAW_DEFS) -O3 -g -gencode arch=compute_70,code=sm_70 -m64 --compiler-options '-g -fPIC -std=c99 -O3 -mavx512f'

ARCH     = ar
ARCHFLAGS= cr
RANLIB   = ranlib

