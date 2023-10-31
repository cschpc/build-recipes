#!/bin/bash

# reset env
module purge

main_dir=$PWD

ase_version=3.22.1
gpaw_version=23.9.1
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
install_tgt=$HOME/tmp/test_gpaw/gpaw/$version
module_base=$HOME/tmp/test_gpaw/modulefiles/gpaw

module_version=${gpaw_version}${openmp}

tmp=$TMPDIR/gpaw_build
tmp_gpaw_git=$tmp/gpaw

rm -rf $tmp
trap "rm -rf $tmp" EXIT

rm -rf $install_tgt
mkdir -p $install_tgt
mkdir -p $module_base

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
$python -m pip install --prefix $install_tgt ase==$ase_version
export PYTHONPATH=$install_tgt/lib/python3.9/site-packages:$PYTHONPATH

git clone https://gitlab.com/gpaw/gpaw.git $tmp_gpaw_git
pushd $tmp_gpaw_git
git checkout $gpaw_git_version
$python -m pip install --verbose --prefix $install_tgt . 2>&1 | tee $main_dir/build-gpaw-$version.log
popd

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

cat > ${module_base}/${module_version}.lua <<EOF
-- GPAW module file

local gpaw_version = '$gpaw_version'
local version = '$version'

if (mode() == "load") then
  LmodMessage("GPAW version " .. gpaw_version .. " is now in use")
  LmodMessage("Release notes: https://wiki.fysik.dtu.dk/gpaw/releasenotes.html")
  LmodMessage("")
  LmodMessage("This module comes with the stable ASE version $ase_version.")
  LmodMessage("")
  LmodMessage("To install the latest ASE development version for testing:")
  LmodMessage("1. Fetch the ASE code (only once):")
  LmodMessage("     git clone https://gitlab.com/ase/ase.git \$HOME/my_ase")
  LmodMessage("     # Checkout the desired development version (commit hash):")
  LmodMessage("     cd \$HOME/my_ase && git checkout <commit hash>")
  LmodMessage("2. Activate this custom ASE (every time after loading gpaw module):")
  LmodMessage("     export PYTHONPATH=\$HOME/my_ase:\$PYTHONPATH")
  LmodMessage("3. Check that the correct versions are used:")
  LmodMessage("     gpaw info")
  LmodMessage("")
end

help('GPAW environment ' .. version)

whatis('Version: ' .. version)
whatis('Description: GPAW density-functional theory software package')
whatis('URL: https://wiki.fysik.dtu.dk/gpaw')

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
chmod -R g=u $module_base
chmod -R o+rX $module_base
