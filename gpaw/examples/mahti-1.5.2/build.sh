### GPAW installation script for Mahti
###   uses --prefix to set a custom installation directory

# version numbers (modify if needed)
gpaw_version=1.5.2
libxc_version=4.3.4
version=$gpaw_version-clang-blis

# installation directory (modify!)
tgt=/appl/soft/phys/gpaw/$version

# setup build environment
module load clang
module load openmpi
module load amdblis/2.2
module load amdlibflame/2.2
module load amdscalapack/2.2
source /appl/soft/phys/gpaw/python/3.7.7/load.sh
export CC=clang
export BLAS_LIBS="blis flame"
export SCALAPACK_LIBS="scalapack"
export LIBXCDIR=/users/jenkovaa/libxc/$libxc_version

# gpaw
if [ -d "gpaw-$gpaw_version" ]
then
    cd gpaw-$gpaw_version
else
    git clone gpaw gpaw-$gpaw_version
    cd gpaw-$gpaw_version
    git checkout $gpaw_version
fi
cp ../setup/customize-mahti.py .
python3 setup.py install --prefix=$tgt --customize=customize-mahti.py | tee ../build-gpaw-$version.log
cd ..

# fix permissions
chmod -R g=u $tgt
chmod -R o+rX $tgt
