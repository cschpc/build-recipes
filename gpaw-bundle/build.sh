### GPAW installation script for Sisu (/Taito)
###   uses PYTHONUSERBASE to bundle all modules into a separate location
###   away from the base python installation

# installation directory (modify!)
tgt=$USERAPPL/gpaw-bundle-2018-04

# version numbers (modify if needed)
numpy_version=1.14.2
scipy_version=1.0.1
ase_version=3.16.0
gpaw_version=1.4.0
libsci_version=16.11.1

# setup build environment
module load scalable-python/1.2
module load cray-hdf5-parallel
module load libxc/3.0.0
module load git
export CC=cc
export FC=ftn
export CXX=CC
export CFLAGS="-fPIC -O2 -fopenmp"
export FFLAGS="-fPIC -O2 -fopenmp"
export LINKFORSHARED='-Wl,-export-dynamic -dynamic'
export MPI_LINKFORSHARED='-Wl,-export-dynamic -dynamic'
export CRAYPE_LINK_TYPE=dynamic
export CRAY_ADD_RPATH=yes

# use --user to install modules
export PYTHONUSERBASE=$tgt
mkdir -p $PYTHONUSERBASE/lib/python2.7/site-packages

# cython + mpi4py
pip install --user cython
pip install --user mpi4py

# numpy
git clone git://github.com/numpy/numpy.git numpy-$numpy_version
cd numpy-$numpy_version
git checkout v$numpy_version
# with MKL (for Taito):
#   sed -e "s|<MKLROOT>|$MKLROOT|g" ../setup/site.cfg-taito-template >| site.cfg
# or w/ libsci (for Sisu):
sed -e 's/<ARCH>/haswell/g' -e "s/<LIBSCI>/$libsci_version/g" ../setup/site.cfg-sisu-template >| site.cfg
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
patch setup.py ../setup/patch-ase.diff
python setup.py install --user 2>&1 | tee loki-inst
cd ..

# gpaw
git clone https://gitlab.com/gpaw/gpaw.git gpaw-$gpaw_version
cd gpaw-$gpaw_version
git checkout $gpaw_version
patch gpaw/test/test.py ../setup/patch-test.diff
ln -s ../setup/gcc.py
python setup.py install --customize=../setup/customize-sisu.py --user 2>&1 | tee loki-inst
cd ..

# fix permissions
chmod -R g+rwX $tgt
chmod -R o+rX $tgt

