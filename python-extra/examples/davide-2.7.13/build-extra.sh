### Python (extra) modules installation script for D.A.V.I.D.E
###   uses PYTHONUSERBASE to bundle all modules into a separate location
###   away from the base python installation

# load Python
source $PYTHONHOME/load.sh

# bundle ID (e.g. time of release) (modify if needed)
bundle=2016-06

# version numbers (modify if needed)
numpy_version=1.10.4
scipy_version=0.17.1
ase_version=3.11.0
pycuda_version=2017.1.1
libxc_version=2.1.3

# installation directory (modify!)
tgt=$PYTHONHOME/bundle/$bundle

# setup build environment
export CFLAGS="-fPIC $CFLAGS"
export FFLAGS="-fPIC $FFLAGS"

# use --user to install modules
export PYTHONUSERBASE=$tgt
mkdir -p $PYTHONUSERBASE/lib/python2.7/site-packages

# build in a separate directory
mkdir bundle-$bundle
cd bundle-$bundle

# cython + mpi4py
pip install --user cython
pip install --user mpi4py

# numpy
git clone git://github.com/numpy/numpy.git numpy-$numpy_version
cd numpy-$numpy_version
git checkout v$numpy_version
sed -e "s|<OPENBLAS_ROOT>|$OPENBLAS_ROOT|g" ../../setup/davide-openblas.cfg > site.cfg
python setup.py build -j 4 install --user 2>&1 | tee loki-inst
cd ..

# scipy
git clone git://github.com/scipy/scipy.git scipy-$scipy_version
cd scipy-$scipy_version
git checkout v$scipy_version
python setup.py build -j 4 install --user 2>&1 | tee loki-inst
cd ..

# ase
git clone https://gitlab.com/ase/ase.git ase-$ase_version
cd ase-$ase_version
git checkout $ase_version
python setup.py install --user 2>&1 | tee loki-inst
cd ..

# libxc
git clone https://gitlab.com/libxc/libxc.git libxc-$libxc_version
cd libxc-$libxc_version
git checkout $libxc_version
libtoolize
aclocal
autoheader
autoconf
automake --add-missing
# or simply
# tar xvfz ~/src/libxc-${libxc_version}.tar.gz
./configure --prefix=$PYTHONUSERBASE --enable-shared | tee loki-conf
make | tee loki-make
make install | tee loki-inst
export LD_LIBRARY_PATH=$PYTHONUSERBASE/lib:$LD_LIBRARY_PATH
cd ..

# pycuda
pip install --user pycuda==$pycuda_version

# go back to the main build directory
cd ..

# if this is the first bundle, use it as default
if [ ! -e $PYTHONHOME/bundle/default ]
then
    cd $PYTHONHOME/bundle
    ln -s $bundle default
    cd -
fi

# fix permissions
chmod -R g+rwX $tgt
chmod -R o+rX $tgt
