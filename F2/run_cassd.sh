#!/bin/bash -x

source common.sh

function iteration ()
{
  cat << EOF | sbatch -J $1.cassd $SBATCH_ARGS $WAIT
#!/bin/bash
source common.sh

run_cassd $1
grep_CASSD_energy $1 

EOF
}

# Execution
rm -f data_CASSD
distance_loop 


