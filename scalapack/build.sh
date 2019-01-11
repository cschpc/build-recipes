### ScaLAPACK installation script for D.A.V.I.D.E

# version numbers (modify if needed)
scalapack_version=2.0.2

# installation directory (modify!)
tgt=$CINECA_SCRATCH/lib/scalapack-${scalapack_version}

# setup build environment
module load cuda/9.2.88
module load cudnn/7.1.4--cuda--9.2.88
module load gnu/6.4.0
module load openmpi/3.1.0--gnu--6.4.0
source $CINECA_SCRATCH/lib/openblas-0.3.4-openmp/load.sh
export CFLAGS="-mcpu=power8 -O3"
export FFLAGS="-mcpu=power8 -O3"

# scalapack
tar xvfz ~/scalapack-${scalapack_version}.tgz
cd scalapack-${scalapack_version}
mkdir build
cd build
cmake -DBLAS_LIBRARIES=$OPENBLAS_ROOT/lib/libopenblas.so -DLAPACK_LIBRARIES=$OPENBLAS_ROOT/lib/libopenblas.so -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$tgt ..
make 2>&1 | tee loki-make
make install 2>&1 | tee loki-install
sed -e "s|<BASE>|$tgt|g" ../../setup/load-scalapack.sh > $tgt/load.sh
cd ../..

# fix permissions
chmod -R g+rwX $tgt
chmod -R o+rX $tgt
