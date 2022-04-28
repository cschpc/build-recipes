#!/bin/bash

# reset env
module purge

gpaw_version=20.10.0
gpaw_git_version=${gpaw_version}
#openmp=""
openmp="-omp"

modules=('gcc/11.2.0' 'openmpi/4.1.2' 'openblas/0.3.18-omp' 'fftw/3.3.10-mpi' 'netlib-scalapack/2.1.0')
module load ${modules[@]}
version=$gpaw_version-gcc-openblas-elpa$openmp

install_tgt=/appl/soft/phys/gpaw/$version
module_base=/appl/modulefiles/gpaw
module_version=${gpaw_version}${openmp}

spack_view=/appl/spack/v017/views/gpaw-python3.9/
export PATH=$spack_view/bin:$PATH
python=python3.9

export CC=gcc

export BLAS_LIBS="openblas"
export SCALAPACK_LIBS="scalapack"
export ELPADIR="/appl/spack/v017/install-tree/gcc-11.2.0/elpa-2021.05.001-a3dh2f"

if [ -n "$openmp" ]
then
  export GPAW_CONFIG=`pwd`/setup/customize-mahti-mt-elpa.py
else
  export GPAW_CONFIG=`pwd`/setup/customize-mahti-elpa.py
fi

libxc_version=4.3.4
export LIBXCDIR=/users/jenkovaa/libxc/$libxc_version
#export LIBXCDIR=/appl/spack/v017/install-tree/gcc-11.2.0/libxc-5.1.5-oa6ihp

if [ -d "gpaw-$gpaw_git_version" ] 
then
    cd gpaw-$gpaw_git_version
else
    cd gpaw
    git fetch origin
    cd ..
    git clone gpaw gpaw-$gpaw_git_version
    cd gpaw-$gpaw_git_version
    git checkout $gpaw_git_version
fi

# Clean up possible previous build
$python setup.py clean -a

$python -m pip install --verbose --prefix $install_tgt . 2>&1 | tee  ../build-gpaw-$version.log
cd ..

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
end

help('GPAW environment ' .. version)

whatis('Version: ' .. version)
whatis('Description: GPAW density-functional theory software package')
whatis('URL: https://wiki.fysik.dtu.dk/gpaw')

depends_on($depend_clause)

gpaw_base = '$install_tgt'
python_base = '$spack_view'

prepend_path('PYTHONPATH', pathJoin(gpaw_base, 'lib/python3.9/site-packages'))
prepend_path('PYTHONPATH', pathJoin(gpaw_base, 'lib64/python3.9/site-packages'))
prepend_path('PYTHONPATH', pathJoin(python_base, 'lib/python3.9/site-packages'))
prepend_path('PYTHONPATH', pathJoin(python_base, 'lib64/python3.9/site-packages'))
prepend_path('PATH', pathJoin(gpaw_base, 'bin'))
prepend_path('PATH', pathJoin(python_base, 'bin'))
prepend_path('LD_LIBRARY_PATH', pathJoin(python_base, 'lib'))

setenv('GPAW_SETUP_PATH', '/appl/soft/phys/gpaw-setups/gpaw-setups-0.9.20000')

EOF
if [ -z "$openmp" ]
then
  echo "setenv('OMP_NUM_THREADS', 1)" >> ${module_base}/${module_version}.lua
fi

# fix permissions
chmod -R g=u $install_tgt
chmod -R o+rX $install_tgt
chmod -R g=u $module_base
chmod -R o+rX $module_base
