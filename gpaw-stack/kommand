# volatile version numbers
python_version=2.7.10
cython_version=0.23.4
nose_version=1.3.7
libxc_version=2.1.2
numpy_version=1.11.1
setups_version=0.9.11271
ase_version=3.13.0
gpaw_version=1.2.0

# base directory
base=/scratch/louhivuo/gpaw-2017-03

# load compile stack
source /opt/intel/compilers_and_libraries_2017.0.098/linux/mpi/bin64/mpivars.sh
source /opt/intel/compilers_and_libraries_2017.0.098/linux/bin/compilervars.sh intel64
export CC=icc
export MPICC=mpiicc

# python
git clone https://github.com/python/cpython
cd cpython
git checkout v$python_version
./configure --prefix=$base/python-$python_version --without-gcc --enable-unicode=ucs4 | tee loki-conf
make 2>&1 | tee loki-make
make install 2>&1 | tee loki-inst
cd ..

export PYTHONHOME=$base/python-$python_version
export PYTHONPATH=$base/python-$python_version/lib
export PATH=$base/python-$python_version/bin:$PATH

# nose
git clone https://github.com/nose-devs/nose/ nose-$nose_version
cd $nose_version
git checkout release_$nose_version
python setup.py install 2>&1 | tee loki-inst
cd ..

# cython
git clone git://github.com/cython/cython cython-$cython_version
cd cython-$cython_version
git checkout $cython_version
python setup.py install 2>&1 | tee loki-inst
cd ..

# optimise/vectorise numerical code
export FFLAGS='-O3 -xMIC-AVX512 -qopenmp -fp-model strict'
export CFLAGS='-O3 -xMIC-AVX512 -qopenmp -fp-model strict -fPIC -fomit-frame-pointer'

# debug
export FFLAGS="-qopt-report=5 -g $FFLAGS"
export CFLAGS="-qopt-report=5 -g $CFLAGS"

# numpy
git clone git://github.com/numpy/numpy.git numpy-$numpy_version
cd numpy-$numpy_version
git checkout v$numpy_version
cp ../setup/site.cfg .
sed -e "s|<FFLAGS>|$FFLAGS|g" ../setup/patch-intel-fcompiler.diff > patch-intel-fcompiler.diff
sed -e "s|<CFLAGS>|$CFLAGS|g" ../setup/patch-intel-ccompiler.diff > patch-intel-ccompiler.diff
patch numpy/distutils/fcompiler/intel.py patch-intel-fcompiler.diff
patch numpy/distutils/intelccompiler.py patch-intel-ccompiler.diff
python setup.py config --compiler=intelem build_clib --compiler=intelem build_ext --compiler=intelem install 2>&1 | tee loki-inst
cd ..

# libxc
wget http://www.tddft.org/programs/octopus/down.php?file=libxc/libxc-$libxc_version.tar.gz
tar xvfz libxc-$libxc_version.tar.gz
cd libxc-$libxc_version
./configure --prefix=$base/libxc-$libxc_version --enable-shared | tee loki-conf
make 2>&1 | tee loki-make
make install 2>&1 | tee loki-inst
cd ..

export LIBXCDIR=$base/libxc-$libxc_version
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$base/libxc-$libxc_version/lib

# unset compile flags
unset CFLAGS
unset FFLAGS

# gpaw-setups
wget https://wiki.fysik.dtu.dk/gpaw-files/gpaw-setups-$setups_version.tar.gz
tar xvfz gpaw-setups-$setups_version.tar.gz
mv -i gpaw-setups-$setups_version $base/

export GPAW_SETUP_PATH=$base/gpaw-setups-$setups_version

# ASE
git clone https://gitlab.com/ase/ase.git ase-$ase_version
cd ase-$ase_version
git checkout $ase_version
export PYTHONUSERBASE=$base/ase-$ase_version
python setup.py install --user 2>&1 | tee loki-inst
unset PYTHONUSERBASE

export PYTHONPATH=$base/ase-$ase_version/lib/python2.7/site-packages:$PYTHONPATH
export PATH=$base/ase-$ase_version/bin:$PATH

# GPAW
git clone https://gitlab.com/gpaw/gpaw.git gpaw-$gpaw_version
cd gpaw-$gpaw_version
git checkout $gpaw_version
cp ../setup/customize-knl.py .
tgt=$base/gpaw-$gpaw_version
python setup.py install --customize=customize-knl.py --prefix=$tgt 2>&1 | tee loki-inst
rm -r $tgt/lib/python
mv -i $tgt/lib/python2.7/site-packages $tgt/lib/python
rmdir $tgt/lib/python2.7

# set up a script for loading the stack
cd ..
sed -e "s|<BASE>|$base|" \
    -e "s|<PYTHON>|$python_version|" \
    -e "s|<LIBXC>|$libxc_version|" \
    -e "s|<SETUPS>|$setups_version|" \
    -e "s|<ASE>|$ase_version|" \
    -e "s|<GPAW>|$gpaw_version|" setup/load.sh > $base/load.sh

# fix permissions
chmod -R g+rwX $base
chmod -R o+rX $base
