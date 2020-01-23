# target directory for installation
tgt=$USERAPPL/appl/python/2.7.17-cuda

# fetch source code
git clone https://github.com/python/cpython
cd cpython

# checkout correct version
git checkout v2.7.17

# setup build environment
module load gcc/8.3.0
module load cuda/10.1.168
module load mpich/3.3.1
module load intel-mkl/2019.0.4
export CFLAGS='-mavx512f -O3'
export FFLAGS='-mavx512f -O3'

# build and install
./configure --prefix=$tgt --enable-shared --disable-ipv6 --enable-unicode=ucs4 2>&1 | tee loki-conf
make 2>&1 | tee loki-make
make install 2>&1 | tee loki-inst
cd ..

# setup load script
sed -e "s|<BASE>|$tgt|g" load.sh > $tgt/load.sh

# install pip
source $tgt/load.sh
python -m ensurepip
pip install --upgrade pip

# fix permissions
chmod -R g=u $tgt
chmod -R o+rX $tgt

