### Python (extra) modules installation script for Puhti (/Sisu)
###   uses PYTHONUSERBASE to bundle all modules into a separate location
###   away from the base python installation

# load Python
#module load scalable-python/1.2
# or if no module exists:
source $PYTHONHOME/load.sh

# installation directory (modify!)
tgt=$PYTHONHOME/bundle/2019-05

# version numbers (modify if needed)
numpy_version=1.16.3
scipy_version=1.2.1
ase_version=3.17.0

# setup build environment
export CFLAGS='-fPIC -mavx512f -O3 -fopenmp'
export FFLAGS=$CFLAGS
export CPPFLAGS=$CFLAGS

# use --user to install modules
export PYTHONUSERBASE=$tgt
mkdir -p $PYTHONUSERBASE/lib/python3.7/site-packages

# cython + mpi4py
pip install --user cython
pip install --user mpi4py

# numpy
git clone git://github.com/numpy/numpy.git numpy-$numpy_version
cd numpy-$numpy_version
git checkout v$numpy_version
# with MKL (for Puhti):
sed -e "s|<MKLROOT>|$MKLROOT|g" ../setup/puhti.cfg >| site.cfg
# or w/ libsci (for Sisu):
#sed -e 's/<ARCH>/haswell/g' -e "s/<LIBSCI>/$libsci_version/g" ../setup/sisu.cfg >| site.cfg
python3 setup.py build -j 4 install --user 2>&1 | tee loki-inst
cd ..

# scipy
git clone git://github.com/scipy/scipy.git scipy-$scipy_version
cd scipy-$scipy_version
git checkout v$scipy_version
python3 setup.py build -j 4 install --user 2>&1 | tee loki-inst
cd ..

# ase
git clone https://gitlab.com/ase/ase.git ase-$ase_version
cd ase-$ase_version
git checkout $ase_version
patch setup.py ../setup/patch-ase.diff
python3 setup.py install --user 2>&1 | tee loki-inst
cd ..

# set default bundle
if [ ! -e "$(dirname $tgt)/default" ]
then
    cd $(dirname $tgt)
    ln -s $(basename $tgt) default
    cd -
fi

# fix permissions
chmod -R g=u $tgt
chmod -R o+rX $tgt

