#!/bin/bash 

source common.sh

function iteration ()
{
  cat << EOF | sbatch -J $1.mrsc2 $SBATCH_ARGS $WAIT
#!/bin/bash
source common.sh

run_mrsc2 $1
grep_MRSC2_energy $1 

EOF
}

# Execution
rm -f data_MRSC2
distance_loop 


