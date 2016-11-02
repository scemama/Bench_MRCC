#!/bin/bash 

GENERATORS=0.999
SELECTORS=0.9999
NDETMAX=524288

source common.sh

function iteration ()
{
  cat << EOF | sbatch -J $1.cas $SBATCH_ARGS $WAIT
#!/bin/bash
source common.sh

run_cas_qp $1 $GENERATORS $SELECTORS $NDETMAX
grep_CAS_QP_energy $1 

EOF
}

# Execution
rm -f data_CAS
distance_loop 


