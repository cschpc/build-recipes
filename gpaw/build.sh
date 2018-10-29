### GPAW installation script for Sisu (/Taito)
###   uses --prefix to set a custom installation directory

# version numbers (modify if needed)
gpaw_version=1.3.0

# installation directory (modify!)
tgt=/appl/nano/gpaw/$gpaw_version

# setup build environment
module load scalable-python/1.2
module load cray-hdf5-parallel
module load libxc/3.0.0
export CRAYPE_LINK_TYPE=dynamic
export CRAY_ADD_RPATH=yes

# gpaw
git clone https://gitlab.com/gpaw/gpaw.git gpaw-$gpaw_version
cd gpaw-$gpaw_version
git checkout $gpaw_version
patch gpaw/test/test.py ../setup/patch-test.diff
patch gpaw/test/xc/xc.py ../setup/patch-xc.diff
ln -s ../setup/gcc.py
python setup.py install --customize=../setup/customize-sisu.py --prefix=$tgt 2>&1 | tee loki-inst
cd ..

# fix permissions
chmod -R g+rwX $tgt
chmod -R o+rX $tgt

