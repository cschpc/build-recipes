#!/bin/bash

# Which programming paradigms to measure with Score-P
# Source this file where necessary
PARADIGMS_USED=""
PARADIGMS_USED="${PARADIGMS_USED} --compiler"
PARADIGMS_USED="${PARADIGMS_USED} --user"
PARADIGMS_USED="${PARADIGMS_USED} --hip"
PARADIGMS_USED="${PARADIGMS_USED} --nokokkos"
PARADIGMS_USED="${PARADIGMS_USED} --thread=omp:ompt"
PARADIGMS_USED="${PARADIGMS_USED} --mpp=mpi"
