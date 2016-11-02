#!/bin/bash 

GENERATORS=0.999
SELECTORS=0.9999
NDETMAX=524288

source common.sh

function iteration ()
{
  convert_to_qp $1 
}

# Execution
distance_loop 


