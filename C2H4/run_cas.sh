#!/bin/bash 

source common.sh

cat << EOF | sbatch -J $(basename $PWD) ${SBATCH_ARGS}  $WAIT
#!/bin/bash 

source common.sh


function iteration ()
{
  run_point \$1 -f \$2 -t "${METHOD}"
  grep_CAS_energy \$1 
  convert_to_qp \$1 > /dev/null
}


rm -f data_CAS

MULT=3 run_point ${EQUILIBRIUM} -t MP2 
iteration ${EQUILIBRIUM} ${EQUILIBRIUM}.dat 

left_distance_loop 
right_distance_loop 
EOF

