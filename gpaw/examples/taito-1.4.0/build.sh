### GPAW installation script for Sisu (/Taito)
###   uses --prefix to set a custom installation directory

# version numbers (modify if needed)
gpaw_version=1.4.0

# installation directory (modify!)
tgt=/appl/nano/gpaw/$gpaw_version

# setup build environment
module purge
module load gcc/4.9.3
module load mkl/11.3.0
module load intelmpi/5.1.1
source /appl/nano/gpaw/python/2.7.13/load.sh 2018-03
module load hdf5-par/1.8.15
module load libxc/3.0.0
module load git

# gpaw
git clone https://gitlab.com/gpaw/gpaw.git gpaw-$gpaw_version
cd gpaw-$gpaw_version
git checkout $gpaw_version
patch gpaw/test/test.py ../setup/patch-test.diff
patch gpaw/test/xc/xc.py ../setup/patch-xc.diff
ln -s ../setup/gcc.py
python setup.py install --customize=../setup/customize-taito.py --prefix=$tgt 2>&1 | tee loki-inst
cd ..

# fix permissions
chmod -R g+rwX $tgt
chmod -R o+rX $tgt

