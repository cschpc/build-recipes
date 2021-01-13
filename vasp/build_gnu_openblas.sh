module purge
module load gcc/9.3.0 openmpi/4.0.3 openblas/0.3.10 netlib-scalapack/2.1.0 fftw/3.3.8-mpi

cp makefile.include_mahti makefile.include 

version=gnu-openblas
export BIN_DIR=bin-$version
mkdir -p $BIN_DIR

export OMP_FLAGS="" # -qopenmp for intel, -fopenmp for gcc
export OPT_FLAGS="-O3 -ffast-math -march=native -funroll-loops -ffpe-summary='none'"
# export LIBDIR=""
export BLAS="-lopenblas"
export LAPACK=""
export SCALAPACK="-lscalapack"
export FFTW="-lfftw3"
export FFTW_INC=$FFTW_INSTALL_ROOT/include/

make veryclean
make 2>&1 | tee vasp-build-$version.log

