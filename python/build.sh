# target directory for installation
tgt=/appl/soft/phys/gpaw/python/3.11.2

# fetch source code
git clone https://github.com/python/cpython
cd cpython

# checkout correct version
git checkout v3.11.2

# setup build environment
module purge
module load gcc/11.2.0
module load openmpi/4.1.2
module load openblas/0.3.18-omp
export CFLAGS='-march=native -O3'
export FFLAGS=$CFLAGS
export CPPFLAGS=$CFLAGS
export CFLAGS="$CFLAGS -I/appl/spack/v017/install-tree/gcc-11.2.0/libffi-3.3-7xturf/include/ -I/appl/spack/v017/install-tree/gcc-11.2.0/sqlite-3.36.0-rpkijl/include"
export LDFLAGS="-L/appl/spack/v017/install-tree/gcc-11.2.0/libffi-3.3-7xturf/lib64/ -L/appl/spack/v017/install-tree/gcc-11.2.0/sqlite-3.36.0-rpkijl/lib -lsqlite3"
export TCL_ROOT=/appl/spack/v017/install-tree/gcc-11.2.0/tcl-8.6.11-zub3nh/
export TK_ROOT=/appl/spack/v017/install-tree/gcc-11.2.0/tk-8.6.11-25gv4m/
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$TCL_ROOT/lib:$TK_ROOT/lib"
export TCL_LIBRARY=$TCL_ROOT/lib/tcl8.6
export TK_LIBRARY=$TK_ROOT/lib/tk8.6

# build and install
src=$(pwd)
cd $TMPDIR
$src/configure --prefix=$tgt --disable-shared --disable-ipv6 2>&1 | tee loki-conf
make 2>&1 | tee loki-make
make install 2>&1 | tee loki-inst
cd -
cd ..

# setup load script
sed -e "s|<BASE>|$tgt|g" load.sh > $tgt/load.sh

# install pip + wheel
source $tgt/load.sh
python3 -m ensurepip
pip3 install --upgrade pip
pip3 install wheel

# fix permissions
chmod -R g=u $tgt
chmod -R o+rX $tgt
