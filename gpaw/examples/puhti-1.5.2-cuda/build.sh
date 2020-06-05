### GPAW installation script for Puhti
###   uses --prefix to set a custom installation directory

# version numbers (modify if needed)
gpaw_version=cuda
gpaw_commit=111567ee39dd48e106b36b1aab4e6bc1b9961cae
libxc_version=4.3.4

# installation directory (modify!)
tgt=$USERAPPL/appl/gpaw/1.5.2-$gpaw_version

# setup build environment
module load gcc/8.3.0
module load cuda/10.1.168
module load mpich/3.3.1
module load intel-mkl/2019.0.4
source $USERAPPL/appl/python/3.7.3-cuda/load.sh 2019-05
export CFLAGS='-fPIC -mavx512f -O3 -fopenmp'
export FFLAGS='-fPIC -mavx512f -O3 -fopenmp'
export LIBXCDIR=/appl/soft/phys/libxc/$libxc_version

# gpaw
git clone https://gitlab.com/mlouhivu/gpaw.git gpaw-$gpaw_version
cd gpaw-$gpaw_version
git checkout $gpaw_commit
cp ../setup/customize-cuda.py .
ln -s ../setup/gcc.py
cd c/cuda
cp ../../../setup/make.inc .
make 2>&1 | tee loki-make
cd -
python3 setup.py install --customize=../setup/customize-cuda.py --prefix=$tgt 2>&1 | tee loki-inst
cd ..

# fix permissions
chmod -R g=u $tgt
chmod -R o+rX $tgt

