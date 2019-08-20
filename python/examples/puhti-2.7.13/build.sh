# target directory for installation
tgt=/appl/soft/phys/gpaw/python/2.7.13

# fetch source code
git clone https://github.com/python/cpython
cd cpython

# checkout correct version
#  2.7.13 -- 9c1426de7521299f70eb5483e7e25d1c2a73dbbd
git checkout 9c1426de7521299f70eb5483e7e25d1c2a73dbbd

# setup build environment
module load gcc/9.1.0
module load mpich/3.3.1
module load hdf5/1.10.4
module load intel-mkl/2019.0.4
export CFLAGS='-march=cascadelake -O3'
export FFLAGS='-march=cascadelake -O3'

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
chmod -R g+rwX $tgt
chmod -R o+rX $tgt

