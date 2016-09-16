#!/bin/bash 

source common.sh

function iteration ()
{
  cat << EOF | sbatch -J $1.mrcepa $SBATCH_ARGS $WAIT
#!/bin/bash
source common.sh

run_mrcepa $1
grep_MRCEPA_energy $1 

EOF
}

# Execution
rm -f data_MRCEPA
distance_loop 


