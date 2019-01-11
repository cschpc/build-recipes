### Python installation script for D.A.V.I.D.E
###   uses --prefix to set a custom installation directory

# version numbers (modify if needed)
python_version=2.7.13

# installation directory (modify!)
tgt=$CINECA_SCRATCH/lib/python-2018-12-cuda

# setup build environment
module load cuda/9.2.88
module load cudnn/7.1.4--cuda--9.2.88 
module load gnu/6.4.0
module load openmpi/3.1.0--gnu--6.4.0
source $CINECA_SCRATCH/lib/openblas-0.3.4-openmp/load.sh
export CC=gcc
export CFLAGS='-mcpu=power8 -O3'
export CXX=g++
export CXXFLAGS='-mcpu=power8 -O3'
export F77=gfortran
export FFLAGS='-mcpu=power8 -O3'

# python
git clone https://github.com/python/cpython.git python-$python_version
cd python-$python_version
git checkout v$python_version
./configure --prefix=$tgt --enable-shared --disable-ipv6 --enable-unicode=ucs4 2>&1 | tee loki-conf
make 2>&1 | tee loki-make
make install 2>&1 | tee loki-inst
cd ..
sed -e "s|<BASE>|$tgt|g" setup/load-python.sh > $tgt/load.sh

# install pip
source $tgt/load.sh
python -m ensurepip
pip install --upgrade pip

# fix permissions
chmod -R g+rwX $tgt
chmod -R o+rX $tgt
