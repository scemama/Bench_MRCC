#!/bin/bash 

SBATCH_ARGS="-n 1 -N 1 --exclusive"
BASIS="CCD"
METHOD="CAS(6,6)"
DISTANCES="$(seq -w 0.90 0.05 3.00) $(seq 3.20 0.20 4.00) 4.50 8.00"
EQUILIBRIUM="1.10"
DISTANCES="$(seq -w 2.65 0.05 3.00) $(seq 3.20 0.20 4.00) 4.50 8.00"
GEOMETRY="
N
N  1  r
"

source ../src/bench_mrcc.sh

# How to update the variables of the Z-matrix
function update_z_variables ()
{
  ZVARIABLES="r $1"
}


