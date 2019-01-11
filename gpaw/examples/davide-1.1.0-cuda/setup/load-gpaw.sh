#!/bin/bash
module load cuda/9.2.88
module load cudnn/7.1.4--cuda--9.2.88
module load gnu/6.4.0
module load openmpi/3.1.0--gnu--6.4.0
source $CINECA_SCRATCH/lib/openblas-0.3.4-openmp/load.sh
source <PYTHONHOME>/load.sh
source $CINECA_SCRATCH/lib/scalapack-2.0.2/load.sh
export GPAW_SETUP_PATH=$CINECA_SCRATCH/lib/gpaw-setups-0.9.11271
export PATH=<BASE>/bin:$PATH
export PYTHONPATH=<BASE>/lib/python2.7/site-packages:$PYTHONPATH
