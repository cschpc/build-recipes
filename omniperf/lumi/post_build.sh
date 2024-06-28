#!/bin/bash

cd $CW_INSTALLATION_PATH
wget https://github.com/AMDResearch/omniperf/releases/download/v1.1.0-PR1/omniperf-v1.1.0-PR1.tar.gz
tar xfz omniperf-v1.1.0-PR1.tar.gz
cd omniperf-1.1.0-PR1/
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${CW_INSTALLATION_PATH}/1.1.0 ..
make install
