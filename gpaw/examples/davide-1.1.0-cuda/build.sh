### GPAW installation script for D.A.V.I.D.E

# version numbers (modify if needed)
gpaw_version=cuda

# installation directory (modify!)
tgt=$CINECA_SCRATCH/lib/gpaw-${gpaw_version}

# setup build environment
module load cuda/9.2.88
module load cudnn/7.1.4--cuda--9.2.88
module load gnu/6.4.0
module load openmpi/3.1.0--gnu--6.4.0
source $CINECA_SCRATCH/lib/openblas-0.3.4-openmp/load.sh
source $CINECA_SCRATCH/lib/python-2018-12-cuda/load.sh 2016-06
export GPAW_SETUP_PATH=$CINECA_SCRATCH/lib/gpaw-setups-0.9.11271
export CFLAGS=""

# gpaw
git clone https://gitlab.com/mlouhivu/gpaw.git gpaw-$gpaw_version
cd gpaw-$gpaw_version
git checkout $gpaw_version
patch gpaw/eigensolvers/rmm_diis.py ../setup/patch-rmmdiis.diff
cp ../setup/customize-cuda.py .
cd c/cuda
cp ../../../setup/make.inc .
make 2>&1 | tee loki-make
cd -
python setup.py install --customize=customize-cuda.py --prefix=$tgt 2>&1 | tee loki-inst
cd ..
sed -e "s|<BASE>|$tgt|g" -e "s|<PYTHONHOME>|$PYTHONHOME|" setup/load-gpaw.sh > $tgt/load.sh

# fix permissions
chmod -R g+rwX $tgt
chmod -R o+rX $tgt
