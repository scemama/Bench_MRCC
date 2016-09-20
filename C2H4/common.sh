#!/bin/bash 

SBATCH_ARGS="-n 1 -N 1 --exclusive"
BASIS="CCD"
METHOD="CAS(4,4)"
DISTANCES="$(seq -w 0.90 0.05 3.00) $(seq 3.20 0.20 4.00) 4.50"
S2EIG="T"
NSTATES_DIAG=3
EQUILIBRIUM="1.40"
GEOMETRY="
 h
 c    1 hc
 c    2 cc         1 hcc 
 h    2 hc         3 hcc          1 180.
 h    3 hc         2 hcc          4 dih
 h    3 hc         2 hcc          5 180.

hc         1.089
hcc        120.
hch        120.
dih        0.
"

source ../src/bench_mrcc.sh

# How to update the variables of the Z-matrix
function update_z_variables ()
{
  ZVARIABLES="cc  $1"
}


function initialization ()
{
  run_point ${EQUILIBRIUM} -t MP2 
}

