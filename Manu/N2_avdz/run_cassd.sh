#!/bin/bash 

NDETMAX=524288

source common.sh

function iteration ()
{
grep_MRCEPA_energy $1 
grep_MRCC_energy $1 
grep_MRSC2_energy $1 
#qp_run diagonalize_restart_and_save_lowest_state $1.cassd

}

# Execution
#rm -f data_CASSD
distance_loop 


