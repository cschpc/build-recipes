module purge
module load intel openmpi

cp makefile.include_mahti makefile.include 

version=intel-opt
export BIN_DIR=bin-$version
mkdir -p $BIN_DIR

export OMP_FLAGS="" # -qopenmp for intel, -fopenmp for gcc
export OPT_FLAGS="-O3 -fp-model fast=2 -no-prec-div"
export LIBDIR=$MKLROOT/lib/intel64
export BLAS="-lmkl_intel_lp64 -lmkl_sequential -lmkl_core"
export LAPACK=""
export SCALAPACK="-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64"
export FFTW=""
export FFTW_INC=$MKLROOT/include/fftw

# make veryclean
make 2>&1 | tee vasp-build-$version.log

