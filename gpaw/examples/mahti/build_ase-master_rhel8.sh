#!/bin/bash

# reset env
module purge

main_dir=$PWD

ase_git_version=53987ebbdf

version=master-2023-09-28-$ase_git_version

# Production
#install_tgt=/appl/soft/phys/ase/$version
#module_base=/appl/modulefiles/ase/
# Testing
install_tgt=$HOME/tmp/test_ase/ase/$version
module_base=$HOME/tmp/test_ase/modulefiles/ase

# Prepend '.' to the module name to make it hidden
module_version=.${version}

tmp=$TMPDIR/ase_build
tmp_ase_git=$tmp/ase

rm -rf $tmp
trap "rm -rf $tmp" EXIT

rm -rf $install_tgt
mkdir -p $install_tgt
mkdir -p $module_base

spack_view=/appl/spack/v017/views/gpaw-python3.9
python=$spack_view/bin/python3.9


git clone https://gitlab.com/ase/ase.git $tmp_ase_git
pushd $tmp_ase_git
git checkout $ase_git_version
$python -m pip install --verbose --prefix $install_tgt . 2>&1 | tee $main_dir/build-ase-$version.log

# Copy .git/HEAD so that git hash shows up in `ase info`
mkdir -p $install_tgt/lib/python3.9/site-packages/.git
cp .git/HEAD $install_tgt/lib/python3.9/site-packages/.git/
popd

cat > ${module_base}/${module_version}.lua <<EOF
-- ASE module file

local ase_version = '$ase_git_version'
local version = '$version'

if (mode() == "load") then
  LmodMessage("ASE version master-" .. ase_version .. " is now in use")
  LmodMessage("Release notes: https://wiki.fysik.dtu.dk/ase/releasenotes.html")
  LmodMessage("")
  LmodMessage("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
  LmodMessage("! Note!                                                        !")
  LmodMessage("! This module gives EXPERIMENTAL development version of ASE,   !")
  LmodMessage("! which can be unstable and buggy! Use with caution and test   !")
  LmodMessage("! the correctness of the results!                              !")
  LmodMessage("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
end

help('ASE ' .. version)

whatis('Version: ' .. version)
whatis('Description: Atomic Simulation Environment')
whatis('URL: https://wiki.fysik.dtu.dk/ase')

python_base = '$spack_view'
ase_base = '$install_tgt'

prepend_path('PYTHONPATH', pathJoin(python_base, 'lib/python3.9/site-packages'))
prepend_path('PYTHONPATH', pathJoin(ase_base, 'lib/python3.9/site-packages'))
prepend_path('PATH', pathJoin(python_base, 'bin'))
prepend_path('PATH', pathJoin(ase_base, 'bin'))
prepend_path('LD_LIBRARY_PATH', pathJoin(python_base, 'lib'))

setenv('MPLBACKEND', 'TkAgg')
EOF

# fix permissions
chmod -R g=u $install_tgt
chmod -R o+rX $install_tgt
chmod -R g=u $module_base
chmod -R o+rX $module_base
