# volatile version number
gpaw_version=1.3.0

# get source code
git clone https://gitlab.com/gpaw/gpaw.git gpaw-$gpaw_version
cd gpaw-$gpaw_version
git checkout $gpaw_version

# load build environment
module swap PrgEnv-cray PrgEnv-gnu
module load cray-hdf5-parallel
module load gpaw-setups/0.9.11271
module load libxc/3.0.0
module load scalable-python/1.2

export CRAYPE_LINK_TYPE=dynamic
export CRAY_ADD_RPATH=yes

# set target directory
tgt=/appl/nano/gpaw/$gpaw_version

# patch the test suite
patch gpaw/test/test.py ../setup/patch-test.diff
patch gpaw/test/xc/xc.py ../setup/patch-xc.diff

# install and fix dirs
ln -s ../setup/gcc.py
python setup.py install --customize=../setup/customize-sisu.py --prefix=$tgt 2>&1 | tee loki-inst
cd ..

# fix permissions
chmod -R g+rwX $tgt
chmod -R o+rX $tgt

