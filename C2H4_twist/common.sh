#!/bin/bash 

SBATCH_ARGS="-n 1 -N 1 --exclusive"
BASIS="CCD"
METHOD="CAS(2,2)"
DISTANCES="$(seq -w 0.0 10. 90.0) "
EQUILIBRIUM="0.0"
GEOMETRY="
 c
 c    1 cc
 h    1 hc         2 hcc  
 h    2 hc         1 hcc          3 dih   
 h    2 hc         1 hcc          3 180.
 h    1 hc         3 hch          2 180.

cc         1.335
hc         1.089
hcc        120.
hch        120.
"

source ../src/bench_mrcc.sh

# How to update the variables of the Z-matrix
function update_z_variables ()
{
  ZVARIABLES="dih  $1"
}


