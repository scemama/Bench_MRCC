#!/bin/bash 

SBATCH_ARGS="-n 1 -N 1 --exclusive"
BASIS="CCD"
METHOD="CAS(2,2)"
DISTANCES="$(seq -w 0.0 0.2 4.0) "
EQUILIBRIUM="4.0"
GEOMETRY="
be
x    1 z
x    1 x       2   90.000
x    1 z       3   90.000      2 180.000
h    2 x       4   90.000      3   0.000
h    4 x       2   90.000      3   0.000

"

source ../src/bench_mrcc.sh

# How to update the variables of the Z-matrix
function update_z_variables ()
{
  ZVARIABLES=$(python -c "print \"z  %f\nx  %f\"%( (2.54-0.46*${1})*0.529177249, ${1}*0.529177249+1.e-6)")
}


