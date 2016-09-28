#!/bin/bash 

LAMBDA=${1:-0}
GENERATORS=0.999
SELECTORS=0.9999
NDETMAX=524288

source common.sh

function iteration ()
{
  cat << EOF | sbatch -J $1.mrcc $SBATCH_ARGS $WAIT
#!/bin/bash
source common.sh


run_mrcc $1 $LAMBDA $GENERATORS $SELECTORS $NDETMAX
grep_MRCC_energy $1 

EOF
}

# Execution
rm -f data_MRCC
distance_loop 


