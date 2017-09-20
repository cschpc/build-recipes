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
PYTHONINCdir ?= $(PYTHONHOME)/include/python2.7/
PYTHONLIBdir ?= $(PYTHONHOME)/lib/
NUMPYINCdir  ?= `python -c "import numpy; print numpy.get_include()"`
MPIINCdir    ?= /appl/opt/openmpi/2.0.1-cuda/gcc/4.9.3/include/
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
CCFLAGS      = $(CUGPAW_DEFS) -g -fPIC -std=c99 -m64 -O3

NVCC           = nvcc
NVCCFLAGS      = $(CUGPAW_DEFS) -O3 -g -arch=sm_20 -m64 --compiler-options '-O3 -g -std=c99 -fPIC' 


ARCH     = ar
ARCHFLAGS= cr
RANLIB   = ranlib


