# target directory for installation
# modified on 15.4.2025

version=3.13.3
tgt=/projappl/project_2002078/python/${version}-perf

mkdir -p ${tgt}

script_dir=$(pwd)
cd $TMPDIR

# fetch source code
git clone https://github.com/python/cpython
cd cpython
src=$(pwd)

# checkout correct version
git checkout v${version}

# setup build environment
module purge
module load gcc/11.3.0
module load openmpi/4.1.4

# perf likes -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer
# see: https://docs.python.org/3/howto/perf_profiling.html#how-to-obtain-the-best-results
export CFLAGS='-march=native -O3 -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer'
export FFLAGS=$CFLAGS
export CPPFLAGS=$CFLAGS

lib_prefix=/appl/spack/v018/install-tree/gcc-11.3.0

export TCL_ROOT=${lib_prefix}/tcl-8.6.12-3ycyko
export TK_ROOT=${lib_prefix}/tk-8.6.11-6zbavi
export TCL_LIBRARY=${TCL_ROOT}/lib/tcl8.6
export TK_LIBRARY=${TK_ROOT}/lib/tk8.6

export CFLAGS="$CFLAGS -I${lib_prefix}/gdbm-1.19-bwdskf/include"
export CFLAGS="$CFLAGS -I${lib_prefix}/libffi-3.4.2-l3lpph/include"
export CFLAGS="$CFLAGS -I${lib_prefix}/sqlite-3.38.5-mu7dxs/include"
export CFLAGS="$CFLAGS -I${TCL_ROOT}/include"
export CFLAGS="$CFLAGS -I${TK_ROOT}/include"

export LDFLAGS="-L${lib_prefix}/gdbm-1.19-bwdskf/lib"
export LDFLAGS="$LDFLAGS -L${lib_prefix}/libffi-3.4.2-l3lpph/lib64"
export LDFLAGS="$LDFLAGS -L${lib_prefix}/sqlite-3.38.5-mu7dxs/lib -lsqlite3"
export LDFLAGS="$LDFLAGS -L${TCL_ROOT}/lib"
export LDFLAGS="$LDFLAGS -L${TK_ROOT}/lib"

export LD_LIBRARY_PATH="${lib_prefix}/gdbm-1.19-bwdskf/lib:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${lib_prefix}/libffi-3.4.2-l3lpph/lib64:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${lib_prefix}/sqlite-3.38.5-mu7dxs/lib:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${TCL_ROOT}/lib:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${TK_ROOT}/lib:${LD_LIBRARY_PATH}"

export TCLTK_LIBS="-L${TCL_LIBRARY} -L${TK_LIBRARY} -ltk8.6 -ltcl8.6"
export TCLTK_CFLAGS="-I${TCL_ROOT}/include -I${TK_ROOT}/include"

set -xe

# build and install
cd $TMPDIR
$src/configure --prefix=$tgt --disable-shared --disable-ipv6 --with-valgrind --with-dtrace --enable-profiling 2>&1 | tee loki-conf
make -j 12 2>&1 | tee loki-make
make install 2>&1 | tee loki-inst
cd -
cd ..

# setup load script
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
