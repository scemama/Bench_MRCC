#!/bin/bash 

BASIS="CCD"
METHOD="CAS(2,2)"
#DISTANCES="$(seq -w 0.90 0.05 3.00) $(seq 3.20 0.20 4.00) 4.50 8.00"
DISTANCES="$(seq -w 0.90 .5 3.00)"
EQUILIBRIUM="1.40"
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


# Initialization : the 1st set of MOs
function initialization ()
{
  run_point ${EQUILIBRIUM} -t MP2 
}


# Initialization : what to do at each iteration
function iteration ()
{
  run_point $1 -f $2 -t ${METHOD} 
}


# Execution
initialization 
iteration $EQUILIBRIUM $EQUILIBRIUM.dat
exit 0
left_distance_loop 
right_distance_loop 


