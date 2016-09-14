#!/bin/bash 

SBATCH_ARGS="-n 1 -N 1 --exclusive"
BASIS="CCD"
METHOD="CAS(2,2)"
DISTANCES="$(seq -w 1.10 0.05 3.00) $(seq 3.20 0.20 4.00) 4.50 8.00"
EQUILIBRIUM="1.55"
S2EIG="T"
GEOMETRY="
 c
 c    1 cc
 h    1 hc3         2 hcc3
 h    1 hc3         2 hcc3          3 dih4
 h    1 hc3         2 hcc3          4 dih4
 h    2 hc3         1 hcc3          3 dih6
 h    2 hc3         1 hcc3          3 dih7
 h    2 hc3         1 hcc3          3 dih8

hc3         1.103
hcc3        111.2
dih4        120.000
dih6         60.000
dih7        180.000
dih8        -60.000
"

source ../src/bench_mrcc.sh

# How to update the variables of the Z-matrix
function update_z_variables ()
{
  ZVARIABLES="cc  $1"
}


