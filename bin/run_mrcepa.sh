#!/bin/bash 

LAMBDA=0
GENERATORS=0.999
SELECTORS=0.9999
NDETMAX=524288

source common.sh



function iteration ()
{
  cat << EOF | sbatch -J $1.mrcepa $SBATCH_ARGS $WAIT
#!/bin/bash
source common.sh

run_mrcepa $1 $LAMBDA $GENERATORS $SELECTORS $NDETMAX
grep_MRCEPA_energy $1 

EOF
}

# Execution
rm -f data_MRCEPA
distance_loop 


