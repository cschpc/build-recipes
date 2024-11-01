#!/bin/bash

cd $CW_INSTALLATION_PATH

wget https://github.com/ROCm/rocprofiler-compute/releases/download/v2.1.0/omniperf-v2.1.0.tar.gz
tar xfz omniperf-v2.1.0.tar.gz
cd omniperf-2.1.0/
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${CW_INSTALLATION_PATH}/2.1.0 ..
make install
