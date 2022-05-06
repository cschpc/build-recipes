### GPAW installation script for Mahti
###   uses --prefix to set a custom installation directory

# version numbers (modify if needed)
gpaw_version=20.1.0
gpaw_git_version=$gpaw_version
libxc_version=4.3.4
version=$gpaw_version-gcc-openblas

# installation directory (modify!)
tgt=/appl/soft/phys/gpaw/$version

# setup build environment
module purge
unset PYTHONPATH
module load gcc
module load openmpi
module load openblas/0.3.10
module load netlib-scalapack/2.1.0
source /appl/soft/phys/gpaw/python/3.8.2/load.sh gpaw-$gpaw_version
export CC=gcc
export BLAS_LIBS="openblas"
export SCALAPACK_LIBS="scalapack"
export GPAW_CONFIG=$(pwd)/setup/siteconfig-mahti.py
export LIBXCDIR=/users/jenkovaa/libxc/$libxc_version

# gpaw
if [ -d "gpaw-$gpaw_git_version" ]
then
    cd gpaw-$gpaw_git_version
else
    git clone gpaw $gpaw_git_version
    cd gpaw-$gpaw_git_version
    git checkout $gpaw_git_version
fi
patch -N < ../setup/config.patch
patch -N < ../setup/setup.patch
patch -N -p1 < ../setup/calculator.patch
patch -N -p1 < ../setup/eigensolver.patch
patch -N -p1 < ../setup/fdpw.patch
patch -N -p1 < ../setup/hirshfeld.patch
patch -N -p1 < ../setup/paw.patch
patch -N -p1 < ../setup/lrtdfft2.patch
python3 -m pip install --verbose --prefix $tgt . 2>&1 | tee  ../build-gpaw-$version.log
cd ..

# fix permissions
chmod -R g=u $tgt
chmod -R o+rX $tgt
