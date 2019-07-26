### GPAW installation script for Sisu (/Taito)
###   uses --prefix to set a custom installation directory

# version numbers (modify if needed)
gpaw_version=1.4.0
libxc_version=3.0.0

# installation directory (modify!)
tgt=/appl/soft/phys/gpaw/$gpaw_version

# setup build environment
module load gcc/9.1.0
module load hpcx-mpi/2.4.0
module load hdf5/1.10.4
module load intel-mkl/2019.0.4
source /appl/soft/phys/gpaw/python/2.7.13/load.sh 2018-03
export CFLAGS='-fPIC -march=cascadelake -O3 -fopenmp'
export FFLAGS='-fPIC -march=cascadelake -O3 -fopenmp'
export LIBXCDIR=/appl/soft/phys/libxc/$libxc_version

# gpaw
git clone https://gitlab.com/gpaw/gpaw.git gpaw-$gpaw_version
cd gpaw-$gpaw_version
git checkout $gpaw_version
patch gpaw/test/test.py ../setup/patch-test.diff
patch gpaw/test/xc/xc.py ../setup/patch-xc.diff
ln -s ../setup/gcc.py
python setup.py install --customize=../setup/customize-puhti.py --prefix=$tgt 2>&1 | tee loki-inst
cd ..

# fix permissions
chmod -R g+rwX $tgt
chmod -R o+rX $tgt

