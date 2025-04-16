#!/bin/bash

version=3.8.6-17100

ml purge
ml PrgEnv-cray

cd /flash/project_462000007/$USER
wget https://water.usgs.gov/water-resources/software/PHREEQC/iphreeqc-$version.tar.gz
tar -xzf iphreeqc-$version.tar.gz
cd iphreeqc-$version

prefix=/projappl/project_462000007/apps/iphreeqc
mkdir -p $prefix/Release
mkdir -p $prefix/RelWithDebInfo

# Release
./configure CC=cc CXX=CC FC=ftn CFLAGS='-fno-omit-frame-pointer' --prefix=$prefix/Release
make -j 12
make install

make clean
make distclean

# Release with debug info
./configure CC=cc CXX=CC FC=ftn CFLAGS='-g -fno-omit-frame-pointer' --prefix=$prefix/RelWithDebInfo
make -j 12
make install
