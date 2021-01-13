### GPAW installation script for Puhti
###   uses --prefix to set a custom installation directory

# version numbers (modify if needed)
gpaw_version=cuda
gpaw_commit=111567ee39dd48e106b36b1aab4e6bc1b9961cae
libxc_version=4.3.4

# installation directory (modify!)
tgt=$PROJAPPL_HPC/appl/gpaw/20.1.0-${gpaw_version}

# setup build environment
module purge
module load gcc/9.1.0
module load hpcx-mpi/2.4.0
module load cuda/11.1.0
module load intel-mkl/2019.0.4
source $PROJAPPL_HPC/appl/python/3.8.3-cuda/load.sh 2020-01
export CFLAGS='-fPIC -march=cascadelake -O3 -fopenmp'
export FFLAGS='-fPIC -march=cascadelake -O3 -fopenmp'
export LIBXCDIR=/appl/soft/phys/libxc/$libxc_version
export GPAW_CONFIG=$(pwd)/setup/siteconfig-puhti-cuda.py

# gpaw
git clone https://gitlab.com/mlouhivu/gpaw.git gpaw-$gpaw_version
cd gpaw-$gpaw_version
git checkout $gpaw_commit
#patch gpaw/test/test.py ../setup/test.patch
patch gpaw/test/xc/xc.py ../setup/xc.patch
patch config.py ../setup/config.patch
patch setup.py ../setup/setup.patch
patch gpaw/calculator.py ../setup/calculator.patch
patch gpaw/paw.py ../setup/paw.patch
patch gpaw/eigensolvers/eigensolver.py ../setup/eigensolver.patch
patch gpaw/wavefunctions/fdpw.py ../setup/fdpw.patch
patch gpaw/lrtddft2/__init__.py ../setup/lrtdfft2.patch
cp ../setup/gcc.py .
cd c/cuda
cp ../../../setup/make.inc .
make 2>&1 | tee loki-make
cd -
pip3 install --verbose --prefix=$tgt . 2>&1 | tee loki-inst
cd ..

# fix permissions
chmod -R g=u $tgt
chmod -R o+rX $tgt

