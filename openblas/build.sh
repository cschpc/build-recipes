### OpenBLAS installation script for D.A.V.I.D.E

# version numbers (modify if needed)
openblas_version=0.3.4

# installation directory (modify!)
tgt=$CINECA_SCRATCH/lib/openblas-${openblas_version}-openmp

# setup build environment
module load cuda/9.2.88
module load cudnn/7.1.4--cuda--9.2.88 
module load gnu/6.4.0
module load openmpi/3.1.0--gnu--6.4.0
export CC=gcc
export CFLAGS='-mcpu=power8 -O3'
export CXX=g++
export CXXFLAGS='-mcpu=power8 -O3'
export FC=gfortran
export FFLAGS='-mcpu=power8 -O3'

# openblas
git clone https://github.com/xianyi/OpenBLAS
cd OpenBLAS
git checkout v$openblas_version
make TARGET=POWER8 USE_OPENMP=1 2>&1 | tee loki-make
make install PREFIX=$tgt 2>&1 | tee loki-install
sed -e "s|<BASE>|$tgt|g" ../setup/load-openblas.sh > $tgt/load.sh
cd ..

# fix permissions
chmod -R g+rwX $tgt
chmod -R o+rX $tgt
