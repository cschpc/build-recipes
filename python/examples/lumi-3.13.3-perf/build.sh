# target directory for installation
# modified on 16.4.2025

version=3.13.3
tgt=/projappl/project_462000007/apps/python/${version}-perf

mkdir -p ${tgt}

build_dir=/flash/project_462000007/$USER
mkdir -p $build_dir

cd $build_dir

# fetch source code
git clone https://github.com/python/cpython
cd cpython
src=$(pwd)

# checkout correct version
git checkout v${version}

# setup build environment
ml PrgEnv-cray

lib_prefix=/appl/lumi/SW/LUMI-24.03/C/EB
gdbm=${lib_prefix}/gdbm/1.23-cpeCray-24.03
ffi=${lib_prefix}/libffi/3.4.4-cpeCray-24.03
sqlite=${lib_prefix}/SQLite/3.43.1-cpeCray-24.03

# perf likes -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer
# see: https://docs.python.org/3/howto/perf_profiling.html#how-to-obtain-the-best-results
export CFLAGS='-march=native -O3 -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer'
export FCFLAGS=$CFLAGS
export CXXFLAGS=$CFLAGS

export CFLAGS="$CFLAGS -I${gdbm}/include"
export CFLAGS="$CFLAGS -I${ffi}/include"
export CFLAGS="$CFLAGS -I${sqlite}/include"

export LDFLAGS="-L${gdbm}/lib64"
export LDFLAGS="$LDFLAGS -L${ffi}/lib64"
export LDFLAGS="$LDFLAGS -L${sqlite}/lib64 -lsqlite3"

export LD_LIBRARY_PATH="${gdbm}/lib64:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${ffi}/lib64:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${sqlite}/lib64:${LD_LIBRARY_PATH}"

set -xe

# build and install
cd $build_dir
$src/configure CC=cc CXX=CC FC=ftn --prefix=$tgt --disable-shared --disable-ipv6 --with-valgrind --with-dtrace --without-tkinter 2>&1 | tee loki-conf
make -j 12 2>&1 | tee loki-make
make install 2>&1 | tee loki-inst
cd -
cd ..

# setup load script
script_dir=$(dirname $0)
cd ${script_dir}
sed -e "s|<BASE>|$tgt|g" load.sh > $tgt/load.sh

# install pip + wheel
source $tgt/load.sh
python3 -m ensurepip
pip3 install --upgrade pip
pip3 install wheel

# fix permissions
chmod -R g=u $tgt
chmod -R o+rX $tgt
