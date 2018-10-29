### Python (extra) modules installation script for Sisu (/Taito)
###   uses PYTHONUSERBASE to bundle all modules into a separate location
###   away from the base python installation

# command to load Python
py_load="source $PYTHONHOME/load.sh"
# or if a module exists
# py_load="module load scalable-python/1.2"

# installation directory (modify!)
tgt=$PYTHONHOME/bundle/2017-10

# version numbers (modify if needed)
numpy_version=1.13.3
scipy_version=0.19.1
ase_version=3.15.0
libsci_version=16.11.1

# setup build environment
eval $py_load
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
python setup.py install --user 2>&1 | tee loki-inst
cd ..

# fix permissions
chmod -R g+rwX $tgt
chmod -R o+rX $tgt

