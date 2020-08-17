#!/bin/bash

# reset env
module purge
unset PYTHONPATH

gpaw_version=20.1.0
# gpaw_git_version=20.1.0-thread
gpaw_git_version=$gpaw_version

# version=$gpaw_version-gcc-openblas-omp
# module load gcc openmpi openblas/0.3.10-omp netlib-scalapack/2.1.0-omp
version=$gpaw_version-gcc-openblas
module load gcc openmpi openblas/0.3.10 netlib-scalapack/2.1.0

export CC=gcc

export BLAS_LIBS="openblas"
export SCALAPACK_LIBS="scalapack"

# version=$gpaw_version-gcc-blis
# module load gcc openmpi amdblis/2.2 amdlibflame/2.2 amdscalapack/2.2

# export CC=gcc

# export BLAS_LIBS="blis flame"
# export SCALAPACK_LIBS="scalapack"

# export GPAW_CONFIG=`pwd`/setup/customize-mahti-mt.py
export GPAW_CONFIG=`pwd`/setup/customize-mahti.py

source /appl/soft/phys/gpaw/python/3.8.2/load.sh gpaw-$gpaw_version

libxc_version=4.3.4
export LIBXCDIR=/users/jenkovaa/libxc/$libxc_version

tgt=/appl/soft/phys/gpaw/$version


if [ -d "gpaw-$gpaw_git_version" ] 
then
    cd gpaw-$gpaw_git_version
else
    git clone gpaw $gpaw_git_version
    cd gpaw-$gpaw_git_version
    git checkout $gpaw_git_version
fi


# apply patches
patch -N < ../setup/config_20.1.0.patch
patch -N < ../setup/setup_20.1.0.patch
patch -N -p1 < ../setup/calculator_20.1.0.patch
patch -N -p1 < ../setup/eigensolver_20_1.0.patch
patch -N -p1 < ../setup/fdpw_20_1.0.patch
patch -N -p1 < ../setup/hirshfeld.patch
patch -N -p1 < ../setup/xc_as_string.patch
patch -N -p1 < ../setup/lrtdfft2.patch

python3 -m pip install --verbose --prefix $tgt . 2>&1 | tee  ../build-gpaw-$version.log
cd ..

# fix permissions
chmod -R g=u $tgt
chmod -R o+rX $tgt
