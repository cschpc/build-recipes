#!/bin/bash

gpaw_version=1.5.2
# version=$gpaw_version-gcc-openblas
# module load gcc openmpi openblas/0.3.10 netlib-scalapack/2.1.0

# export BLAS_LIBS="openblas"
# export SCALAPACK_LIBS="scalapack"

version=$gpaw_version-clang-blis
module load clang openmpi amdblis/2.2 amdlibflame/2.2 amdscalapack/2.2

export CC=clang

export BLAS_LIBS="blis flame"
export SCALAPACK_LIBS="scalapack"

source /appl/soft/phys/gpaw/python/3.7.7/load.sh 

libxc_version=4.3.4
# libxc_version=2.2.3

tgt=/appl/soft/phys/gpaw/$version

export LIBXCDIR=/users/jenkovaa/libxc/$libxc_version

if [ -d "gpaw-$gpaw_version" ] 
then
    cd gpaw-$gpaw_version
else
    git clone gpaw gpaw-$gpaw_version
    cd gpaw-$gpaw_version
    git checkout $gpaw_version
fi

# cp ../setup/customize-mahti-mt.py .
cp ../setup/customize-mahti.py .
# cp config.py_new config.py


python3 setup.py install --prefix=$tgt --customize=customize-mahti.py | tee ../build-gpaw-$version.log

cd ..

# fix permissions
chmod -R g=u $tgt
chmod -R o+rX $tgt
