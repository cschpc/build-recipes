#!/bin/bash

# INSTALL DIRECTORY
tgt=<TARGET>

# files and directories to install
dirs="benchmarks examples include"
files="LICENSE.txt env.sh README.md CHANGELOG.md"

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

