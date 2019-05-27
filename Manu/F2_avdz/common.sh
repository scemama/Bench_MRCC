#!/bin/bash 

#SBATCH_ARGS="-n 1 -N 1 --exclusive -p moonshot"
SBATCH_ARGS="-n 1 -N 1 --exclusive -p xeonv3,xeonv4"
BASIS="ACCD"
METHOD="CAS(6,6)"
#DISTANCES="$(seq -w 0.90 0.05 3.00) $(seq 3.20 0.20 4.00) 4.50 5.00"
DISTANCES="4.50 5.00 100.0"
#DISTANCES=" $(seq 2.80 0.20 4.00)"
EQUILIBRIUM="1.40"
NSTATES=1
NSTATES_DIAG=8
STATE_FOLLOWING=0
S2EIG=1
THRESH_DAVIDSON="1.e-10"
GEOMETRY="
F
F  1  r
"
NDETMAX=20000000

source ../../src/bench_mrcc.sh

# How to update the variables of the Z-matrix
function update_z_variables ()
{
  ZVARIABLES="r $1"
}

function initialization ()
{
  run_point ${EQUILIBRIUM} -t MP2
}


