#!/bin/bash 

BASIS="CCD"
METHOD="CAS(6,6)"
DISTANCES="$(seq -w 0.90 0.05 3.00) $(seq 3.20 0.20 4.00) 4.50 8.00"
EQUILIBRIUM="1.10"
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
left_distance_loop 
right_distance_loop 


