# volatile version number
libxc_version=4.0.2

# get source code
#   OR alternatively download release tar-ball
git clone https://gitlab.com/libxc/libxc.git libxc-$libxc_version
cd libxc-$libxc_version
git checkout $libxc_version
autoconf

# load build environment
module swap PrgEnv-cray PrgEnv-gnu

# compile
export CC=cc
export CFLAGS="-O3 -ffast-math -funroll-loops -march=haswell -mtune=haswell -mavx2 -fPIC"

# set target directory
tgt=/appl/nano/libxc/$libxc_version

# build and install
./configure --prefix=$tgt 2>&1 | tee loki-conf

make 2>&1 | tee loki-make
make install 2>&1 | tee loki-inst

# fix permissions
chmod -R g+rwX $tgt
chmod -R o+rX $tgt

