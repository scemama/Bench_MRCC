#!/bin/bash

BASIS="CCD"
METHOD="CAS(2,2)"
DISTANCES="$(seq -w 0.90 0.05 3.00) $(seq 3.20 0.20 4.00) 4.50 8.00"
GEOMETRY="
F
F  1  r
"

source ../src/bench_mrcc.sh

function initialization ()
{
  # Create Hartree-Fock at equilibrium distance
  ZVARIABLES="r 1.41"
  print_geometry | create_gamess_input -b $BASIS > hf.inp
  run_gamess hf
  cp hf.dat dat_file

  # Run an MP2 to bring important MOs in the middle
}


initialization 
for d in $DISTANCES
do
  ZVARIABLES="r $d"
  create_gamess_input $d
  
done

