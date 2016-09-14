#!/bin/bash 

JOBID=$(./run_cas.sh 2>&1 | cut -d ' ' -f 4)
export WAIT="-d afterok:$JOBID"
./run_cassd.sh
./run_mrcc.sh
./run_fci.sh
