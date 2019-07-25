### GPAW installation script for Puhti
###   uses conda for the python installation

# version numbers (modify if needed)
gpaw_version=1.5.2
libxc_version=4.3.4

# installation directory (modify!)
base=/appl/soft/phys/gpaw/miniconda3/
tgt=$base/envs/gpaw-$gpaw_version

# setup build environment
module load gcc/9.1.0
module load hpcx-mpi/2.4.0
module load hdf5/1.10.4
module load intel-mkl/2019.0.4
export CFLAGS="-fPIC -O2 -fopenmp"
export FFLAGS="-fPIC -O2 -fopenmp"
export LINKFORSHARED='-Wl,-export-dynamic -dynamic'
export MPI_LINKFORSHARED='-Wl,-export-dynamic -dynamic'
export LIBXCDIR=/appl/soft/phys/libxc/$libxc_version

# build conda
bash Miniconda3-4.6.14-Linux-x86_64.sh
# install dir: /appl/soft/phys/gpaw/miniconda3
source $base/bin/activate
conda update -n base -c defaults conda
conda env create --file environment.yml
conda activate gpaw-$gpaw_version

# gpaw
git clone https://gitlab.com/gpaw/gpaw.git gpaw-$gpaw_version
cd gpaw-$gpaw_version
git checkout $gpaw_version
#patch gpaw/test/test.py ../setup/patch-test.diff
ln -s ../setup/gcc.py
python setup.py install --customize=../setup/customize-puhti.py 2>&1 | tee loki-inst
cd ..

# fix permissions
chmod -R g+rwX $tgt
chmod -R o+rX $tgt
