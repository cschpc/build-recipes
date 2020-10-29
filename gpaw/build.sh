### GPAW installation script for Puhti
###   uses --prefix to set a custom installation directory

# version numbers (modify if needed)
gpaw_version=1.5.2
libxc_version=4.3.4

# installation directory (modify!)
tgt=/appl/soft/phys/gpaw/$gpaw_version

# setup build environment
module load gcc/9.1.0
module load mpich/3.3.1
module load intel-mkl/2019.0.4
source /appl/soft/phys/gpaw/python/3.7.3/load.sh 2019-05
export CFLAGS='-fPIC -march=cascadelake -O3 -fopenmp'
export FFLAGS='-fPIC -march=cascadelake -O3 -fopenmp'
export LIBXCDIR=/appl/soft/phys/libxc/$libxc_version

# gpaw
git clone https://gitlab.com/gpaw/gpaw.git gpaw-$gpaw_version
cd gpaw-$gpaw_version
git checkout $gpaw_version
#patch gpaw/test/test.py ../setup/test.patch
patch gpaw/test/xc/xc.py ../setup/xc.patch
ln -s ../setup/gcc.py
python3 setup.py install --customize=../setup/customize-puhti.py --prefix=$tgt 2>&1 | tee loki-inst
cd ..

# fix permissions
chmod -R g=u $tgt
chmod -R o+rX $tgt

