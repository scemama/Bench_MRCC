#!/bin/bash 

SBATCH_ARGS="-n 1 -N 1 --exclusive"
BASIS="CCD"
MULT=3
METHOD="CAS(2,2)"
DISTANCES="$(seq -w 1.20 0.05 3.00) $(seq 3.20 0.20 4.00) 4.50 8.00"
EQUILIBRIUM="8.00"
GENERATORS="1."
SELECTORS="1."
NSTATES_DIAG=4
PT2MAX=1.e-4
S2EIG="T"
GEOMETRY="
F
F  1  r
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
