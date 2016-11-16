#!/bin/bash 

SBATCH_ARGS="-n 1 -N 1 --exclusive"
BASIS="CCD"
METHOD="CAS(2,5)"
DISTANCES="$(seq 2.00 0.10 8.00)"
EQUILIBRIUM="4.00"
S2EIG="T"
LAMBDA=0
NSTATES=2
GEOMETRY="
F
Li  1  r
"

source ../src/bench_mrcc.sh

# How to update the variables of the Z-matrix
function update_z_variables ()
{
  ZVARIABLES="r $1"
}

function initialization ()
{
  run_point ${EQUILIBRIUM} -t MP2 
}

