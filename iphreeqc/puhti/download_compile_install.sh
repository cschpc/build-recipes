#!/bin/bash

version=3.8.6-17100

ml gcc

cd $TMPDIR
wget https://water.usgs.gov/water-resources/software/PHREEQC/iphreeqc-$version.tar.gz
tar -xzf iphreeqc-$version.tar.gz
cd iphreeqc-$version

prefix=/projappl/project_2013477/iphreeqc
mkdir -p $prefix/Release
mkdir -p $prefix/RelWithDebInfo

# Release
./configure CC=gcc CXX=g++ CFLAGS='-fno-omit-frame-pointer' ---prefix=$prefix/Release
make -j 12
make install

make clean
make distclean

# Release with debug info
./configure CC=gcc CXX=g++ CFLAGS='-g -fno-omit-frame-pointer' --prefix=$prefix/RelWithDebInfo
make -j 12
make install
