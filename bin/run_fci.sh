#!/bin/bash 

source common.sh

GENERATORS=0.999
SELECTORS=0.9999
NDETMAX=524288

function iteration ()
{
  cat << EOF | sbatch -J $1.fci $SBATCH_ARGS $WAIT
#!/bin/bash
source common.sh

run_fci $1 $GENERATORS $SELECTORS $NDETMAX
grep_FCI_energy $1 

EOF
}

# Execution
rm -f data_FCI
distance_loop 


