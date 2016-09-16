#!/bin/bash 

source common.sh

function iteration ()
{
  cat << EOF | sbatch -J $1.fci $SBATCH_ARGS  $WAI $WAIT
#!/bin/bash
source common.sh

run_fci $1
grep_FCI_energy $1 

EOF
}

# Execution
rm -f data_FCI
distance_loop 


