#!/bin/bash
# Usage:
#
# cd .../build-recipes/gpaw
# bash examples/mahti/build_gpaw_rhel8.sh

# reset env
module purge

main_dir=$PWD

ase_version=3.23.0
gpaw_version=24.6.0
gpaw_git_version=${gpaw_version}
#openmp=""
openmp="-omp"

modules=('gcc/11.2.0' 'openmpi/4.1.2' 'openblas/0.3.18-omp' 'fftw/3.3.10-mpi' 'netlib-scalapack/2.1.0')
module load ${modules[@]}
#version=$gpaw_version-gcc-openblas-elpa$openmp
version=$gpaw_version-gcc-openblas$openmp

# Production
#install_tgt=/appl/soft/phys/gpaw/$version
#module_base=/appl/modulefiles/gpaw
# Testing
install_tgt=$PWD/gpaw_test_3/gpaw/$version
module_base=$PWD/gpaw_test_3/modulefiles/my-gpaw

echo "install_tgt=$install_tgt"
echo "module_base=$module_base"
module_version=${gpaw_version}${openmp}
module_file=${module_base}/${module_version}.lua
echo "module_file=$module_file"

if [[ -e "$install_tgt" ]]; then
    echo "ERROR: install_tgt exists"
    exit 1
fi
if [[ -e "$module_file" ]]; then
    echo "ERROR: module_file exists"
    exit 1
fi

mkdir -p $install_tgt
if [[ ! -e "$module_base" ]]; then
    echo "create module_base"
    mkdir -p $module_base
    chmod g=u $module_base
    chmod o+rX $module_base
fi

# tmp=$TMPDIR/gpaw_build
# tmp_gpaw_git=$tmp/gpaw
# rm -rf $tmp
# trap "rm -rf $tmp" EXIT

spack_view=/appl/spack/v017/views/gpaw-python3.9
python=$spack_view/bin/python3.9


if [ -n "$openmp" ]
then
  #export GPAW_CONFIG=$main_dir/setup/siteconfig-mahti-omp-elpa.py
  export GPAW_CONFIG=$main_dir/setup/siteconfig-mahti-omp.py
else
  echo "Not implemented. ELPA has only openmp.so?"
  exit 1
  export GPAW_CONFIG=`pwd`/setup/customize-mahti-elpa.py
fi

# Install ASE for GPAW build (for writing git hash)
$python -m pip install -v --no-build-isolation --prefix $install_tgt ase==$ase_version
export PYTHONPATH=$install_tgt/lib/python3.9/site-packages:$PYTHONPATH

$python -m pip install -v --log $install_tgt/build.log --no-build-isolation --prefix $install_tgt gpaw==$gpaw_version
# git clone https://gitlab.com/gpaw/gpaw.git $tmp_gpaw_git
# pushd $tmp_gpaw_git
# git checkout $gpaw_git_version
# $python -m pip install --verbose --prefix $install_tgt . 2>&1 | tee $install_tgt/build-gpaw-$version.log
# popd

# Install pytest: don't do it! Otherwise pytest prepends this path to sys.path when run -> big mess with other modules!
# $python -m pip install --prefix $install_tgt pytest

# Create the module
depend_clause=""
for module in ${modules[@]}
do
  depend_clause="${depend_clause}'$module', "
done
# remove trailing comma
depend_clause=${depend_clause:0:-2}

cat > $module_file <<EOF
-- GPAW module file

local gpaw_version = '$gpaw_version'
local version = '$version'

if (mode() == "load") then
  LmodMessage("GPAW version " .. gpaw_version .. " is now in use")
  LmodMessage("Release notes: https://gpaw.readthedocs.io/releasenotes.html")
  LmodMessage("This module comes with the stable ASE version $ase_version.")
end

help('GPAW environment ' .. version)

whatis('Version: ' .. version)
whatis('Description: GPAW density-functional theory software package')
whatis('URL: https://gpaw.readthedocs.io')

depends_on($depend_clause)

python_base = '$spack_view'
gpaw_base = '$install_tgt'

prepend_path('PYTHONPATH', pathJoin(python_base, 'lib/python3.9/site-packages'))
prepend_path('PYTHONPATH', pathJoin(gpaw_base, 'lib/python3.9/site-packages'))
prepend_path('PATH', pathJoin(python_base, 'bin'))
prepend_path('PATH', pathJoin(gpaw_base, 'bin'))
prepend_path('LD_LIBRARY_PATH', pathJoin(python_base, 'lib'))

setenv('GPAW_SETUP_PATH', '/appl/soft/phys/gpaw-setups/gpaw-setups-0.9.20000')

setenv('MPLBACKEND', 'TkAgg')
setenv('OMP_NUM_THREADS', 1)
EOF

# fix permissions
chmod -R g=u $install_tgt
chmod -R o+rX $install_tgt
chmod g=u $module_file
chmod o+rX $module_file
