#!/bin/bash 

source common.sh

function iteration ()
{
  cat << EOF | sbatch -J $1.mrcc $SBATCH_ARGS $WAIT
#!/bin/bash
source common.sh

run_mrcc $1
grep_MRCC_energy $1 

EOF
}

# Execution
rm -f data_MRCC
distance_loop 


