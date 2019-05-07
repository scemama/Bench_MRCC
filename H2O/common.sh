#!/bin/bash 

SBATCH_ARGS="-n 1 -N 1 --exclusive"
BASIS="CCD"
METHOD="CAS(4,4)"
DISTANCES="$(seq -w 0.90 0.05 3.0) "
EQUILIBRIUM="1.20"
S2EIG="T"
GEOMETRY="
o 
h 1 d 
h 1 d 2 110.6 
"

source ../src/bench_mrcc.sh

# How to update the variables of the Z-matrix
function update_z_variables ()
{
  ZVARIABLES="d  $1"
}

function initialization ()
{
  run_point ${EQUILIBRIUM} -t MP2 
}

