# target directory for installation
tgt=/appl/soft/phys/gpaw/python/3.7.3

# fetch source code
git clone https://github.com/python/cpython
cd cpython

# checkout correct version
git checkout v3.7.3

# setup build environment
module load gcc/9.1.0
module load mpich/3.3.1
module load hdf5/1.10.4
module load intel-mkl/2019.0.4
export CFLAGS='-march=cascadelake -O3'
export CFLAGS="$CFLAGS -I/appl/spack/install-tree/gcc-9.1.0/libffi-3.2.1-5jujit/lib/libffi-3.2.1/include/"
export FFLAGS=$CFLAGS
export CPPFLAGS=$CFLAGS
export LDFLAGS=-L/appl/spack/install-tree/gcc-9.1.0/libffi-3.2.1-5jujit/lib64

# build and install
./configure --prefix=$tgt --enable-shared --disable-ipv6 2>&1 | tee loki-conf
make 2>&1 | tee loki-make
make install 2>&1 | tee loki-inst
cd ..

# setup load script
sed -e "s|<BASE>|$tgt|g" load.sh > $tgt/load.sh

# install pip
source $tgt/load.sh
python3 -m ensurepip
pip3 install --upgrade pip

# fix permissions
chmod -R g=u $tgt
chmod -R o+rX $tgt

