### GPAW installation script for Puhti
###   uses --prefix to set a custom installation directory

# Start from clean environment
module purge
unset PYTHONPATH
unset PYTHONHOME
unset PYTHONUSERBASE

# version numbers (modify if needed)
gpaw_version=20.1.0
export GPAW_CONFIG=`pwd`/setup/siteconfig_hpcx.py

ase_version=3.19.0
libxc_version=4.3.4

# installation directory (modify!)
tgt=/appl/soft/phys/gpaw/$gpaw_version

# setup build environment
module load gcc/9.1.0
module load hpcx-mpi/2.4.0
module load intel-mkl/2019.0.4

source /appl/soft/phys/gpaw/python/3.8.2/load.sh 

export CFLAGS='-fPIC -march=cascadelake -O3 -fopenmp'
export FFLAGS='-fPIC -march=cascadelake -O3 -fopenmp'
export LIBXCDIR=/appl/soft/phys/libxc/$libxc_version

# gpaw
git clone https://gitlab.com/gpaw/gpaw.git gpaw-$gpaw_version
cd gpaw-$gpaw_version
git checkout $gpaw_version
cp ../setup/gcc.py .
# apply patches
patch -N < ../setup/config_20.1.0.patch
patch -N < ../setup/setup_20.1.0.patch
patch -N -p1 < ../setup/calculator_20.1.0.patch
patch -N -p1 < ../setup/eigensolver_20_1.0.patch
patch -N -p1 < ../setup/fdpw_20_1.0.patch

pip3 install --verbose --prefix $tgt . 2>&1 | tee gpaw-install.log
cd ..

