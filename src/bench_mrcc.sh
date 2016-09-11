#!/bin/bash

# environment
# ===========

f=$(readlink -f "${BASH_SOURCE:-${0}}")
f=${f%/*}
ROOT=${f%/*}
export PATH+=":${ROOT}/bin"

# Default Configuration
# =====================

source ${ROOT}/config
export TMPDIR

# Options
# =======

[[ -z $MULT   ]] && MULT=1
[[ -z $CHARGE ]] && CHARGE=0
[[ -z $S2EIG  ]] && S2EIG=F

OPTIONS="-b $BASIS -c $CHARGE -m $MULT"

# =============

function print_geometry ()
{
  if [[ -z $GEOMETRY ]]
  then
    echo "GEOMETRY not defined"
  fi
  printf "%s\n\n%s\n" "$GEOMETRY" "$ZVARIABLES"
}



function run_gamess ()
{
  # Distance
  FILE=$1
  if [[ -z $FILE ]]
  then
    echo "Error in run_gamess"
    exit 1
  fi

  # Check if TMPDIR is accessible
  if [[ -z $TMPDIR ]] 
  then
    echo "TMPDIR is not defined. Please define TMPDIR"
  fi
  mkdir -p ${TMPDIR}/gamess
  
  echo " [    GAMESS    ] [ $FILE ]"
  rm -f $TMPDIR/${FILE}.*
  $RUNGMS $FILE > $FILE.out 2> $FILE.err
  [[ -f $TMPDIR/$FILE.dat ]] && mv $TMPDIR/$FILE.dat .
  rm -rf $FILE.err
}

function run_fci ()
{
  d=$1                   ; shift
  GENERATORS=${1:-0.999} ; shift
  SELECTORS=${1:-0.9999} ; shift
  NDETMAX=${1:-524288}   ; shift

  EZFIO=$d.fci
  rm -rf $EZFIO
  cp -r $d $EZFIO
  qp_edit -c $EZFIO
  qp_set_frozen_core.py $EZFIO > /dev/null
  echo $NDETMAX > $EZFIO/determinants/n_det_max
  echo F > $EZFIO/perturbation/do_pt2_end
  echo " [  FCI canon   ] [ $FILE ]"
  qp_run fci_zmq $EZFIO > $EZFIO.out
  echo $NDETMAX > $EZFIO/determinants/n_det_max
  echo $GENERATORS > $EZFIO/determinants/threshold_generators
  echo $SELECTORS > $EZFIO/determinants/threshold_selectors
  echo T > $EZFIO/perturbation/do_pt2_end
  qp_run save_natorb $EZFIO >> $EZFIO.out
  echo " [  FCI natorb  ] [ $FILE ]"
  qp_run fci_zmq $EZFIO >> $EZFIO.out
}

function run_cassd ()
{
  d=$1                   ; shift
  GENERATORS=${1:-0.999} ; shift
  SELECTORS=${1:-0.9999} ; shift
  NDETMAX=${1:-524288}   ; shift

  EZFIO=$d.cassd
  rm -rf $EZFIO
  cp -r $d $EZFIO
  NMCC=$(grep NMCC $d.inp | cut -d '=' -f 2)
  NDOC=$(grep NDOC $d.inp | cut -d '=' -f 2)
  NALP=$(grep NALP $d.inp | cut -d '=' -f 2)
  NVAL=$(grep NVAL $d.inp | cut -d '=' -f 2)
  NCORE=$(qp_set_frozen_core.py $EZFIO -q)
  MO_TOT_NUM=$(($(cat $EZFIO/mo_basis/mo_tot_num)))
  qp_edit -c $EZFIO
  qp_set_mo_class $EZFIO -core "[1-$NCORE]" -inact "[$((NCORE+1))-$NMCC]" -act "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" -virt "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
  echo $NDETMAX > $EZFIO/determinants/n_det_max
  echo $GENERATORS > $EZFIO/determinants/threshold_generators
  echo $SELECTORS > $EZFIO/determinants/threshold_selectors
  echo " [    CAS+SD    ] [ $FILE ]"
  qp_run cas_sd_selected $EZFIO > $EZFIO.out
}

function run_mrcc ()
{
  d=$1                   ; shift
  LAMBDA=${1:-0}         ; shift
  GENERATORS=${1:-0.999} ; shift
  SELECTORS=${1:-0.9999} ; shift
  NDETMAX=${1:-524288}   ; shift

  EZFIO=$d.mrcc
  rm -rf $EZFIO
  cp -r $d.cassd $EZFIO
  echo T > $EZFIO/determinants/read_wf
  echo T > $EZFIO/perturbation/do_pt2_end
  echo $LAMBDA > $EZFIO/mrcepa0/lambda_type
  echo $NDETMAX > $EZFIO/determinants/n_det_max
  echo $GENERATORS > $EZFIO/determinants/threshold_generators
  echo $SELECTORS > $EZFIO/determinants/threshold_selectors
  echo " [    MRCCSD    ] [ $FILE ]"
  qp_run mrcc $EZFIO > $EZFIO.out
}

function reorder_distances ()
{
  EQ=$1
  shift
  LESS=1
  for d in $@
  do
     if [[ $d != $EQ ]]
     then
       if [[ $LESS -eq 1 ]]
       then
         LEFT="$d $LEFT"
       else
         RIGHT="$RIGHT $d"
       fi
     else
       LESS=0
     fi
  done
  echo $LEFT
  echo $RIGHT
}

function left_distances ()
{
  reorder_distances $@ | head -1
}


function right_distances ()
{
  reorder_distances $@ | tail -1
}

function right_distance_loop ()
{
  OLD_d=$EQUILIBRIUM
  for d in $(right_distances $EQUILIBRIUM $DISTANCES)
  do
    iteration $d ${OLD_d}.dat
    OLD_d=$d
  done
}

function left_distance_loop ()
{
  OLD_d=$EQUILIBRIUM
  for d in $(left_distances $EQUILIBRIUM $DISTANCES)
  do
    iteration $d ${OLD_d}.dat
    OLD_d=$d
  done
}

function distance_loop ()
{
  OLD_d=$EQUILIBRIUM
  for d in $DISTANCES
  do
    iteration $d ${OLD_d}.dat
    OLD_d=$d
  done
}


function run_point ()
{ 
  d=$1
  shift
  update_z_variables $d
  print_geometry | create_gamess_input $OPTIONS $@ > $d.inp
  run_gamess $d
}

function sort_file ()
{
  sort -n $1 > $1.tmp
  mv $1.tmp $1
}

function convert_to_qp ()
{
  echo " [  QP_CONVERT  ] [ $1 ]"
  qp_convert_output_to_ezfio.py ${1}.out --ezfio=$1
  mkdir -p $1/mrcepa0
  qp_edit -c $1
  echo $S2EIG > $1/determinants/s2_eig
  echo 5.e-4 > $1/perturbation/pt2_max
}

function grep_CAS_energy ()
{
  LINE=$(awk " /TOTAL ENERGY =/ { print \"$1  \", \$4 \"  \"} " $1.out)
  echo " [      CAS     ] [ $LINE ]"
  echo $LINE >> data_CAS
  sort_file data_CAS
}

function grep_FCI_energy ()
{
  EZFIO=$1.fci
  LINE=$(printf "%s  %16.10f\n" $1  $(cat $EZFIO/full_ci/energy_pt2))
  echo " [      FCI     ] [ $LINE ]"
  echo $LINE >> data_FCI
  sort_file data_FCI
}

function grep_CASSD_energy ()
{
  EZFIO=$1.cassd
  E=$(grep "E+PT2   " ${EZFIO}.out | tail -1 | awk '// { print   $3  }')
  LINE=$(printf "%s  %16.10f\n" $1 $E)
  echo " [    CAS+SD    ] [ $LINE ]"
  echo $LINE >> data_CASSD
  sort_file data_CASSD
}

function grep_MRCC_energy ()
{
  EZFIO=$1.mrcc
  E=$(grep "E+PT2   " ${EZFIO}.out | tail -1 | awk '// { print   $3  }')
  LINE=$(printf "%s  %16.10f\n" $1 $E)
  echo " [    MRCCSD    ] [ $LINE ]"
  echo $LINE >> data_MRCC
  sort_file data_MRCC
}

