#!/bin/bash

# INSTALL DIRECTORY
tgt=$USERAPPL/pyMIC-dev

# files and directories to install
dirs="benchmarks examples pymic include"
files="LICENSE.txt env.sh README.md CHANGELOG.md"

mkdir $tgt

for dir in $dirs 
do
	for sub in $(find $dir -type d)
	do
		mkdir $tgt/$sub
	done
	for file in $(find $dir -type f ! -name 'Makefile' ! -name 'clean.bat' ! -name 'make.bat')
	do
		cp $file $tgt/$file
	done
done

for file in $files 
do
	cp $file $tgt/
done

