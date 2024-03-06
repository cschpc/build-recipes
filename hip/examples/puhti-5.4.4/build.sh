### HIP installation script for Puhti

# version numbers (modify if needed)
version=5.4.4

# installation directory (modify!)
tgt=$PROJAPPL/appl/hip/$version

# setup build environment
module load cuda/11.7.0

# hip
git clone -b rocm-$version https://github.com/ROCm-Developer-Tools/hip.git hip-$version
git clone -b rocm-$version https://github.com/ROCm-Developer-Tools/hipamd.git hipamd-$version
hip_dir=$(pwd)/hip-$version
hipamd_dir=$(pwd)/hipamd-$version
mkdir -p $hipamd_dir/build
cd $hipamd_dir/build
cmake -DHIP_COMMON_DIR=$hip_dir -DHIP_PLATFORM=nvidia -DCMAKE_INSTALL_PREFIX=$tgt .. 2>&1 | tee loki-cmake
make -j 4 2>&1 | tee loki-make
make install 2>&1 | tee loki-inst
cd ../..

# fix permissions
chmod -R g=u $tgt
chmod -R o+rX $tgt
