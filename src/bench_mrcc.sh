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
[[ -z $PT2MAX ]] && PT2MAX=5.e-4
[[ -z $NSTATES ]] && NSTATES=1
[[ -z $NSTATES_DIAG ]] && NSTATES_DIAG=10
[[ -z $THRESH_DAVIDSON ]] && THRESH_DAVIDSON=1.e-12
[[ -z $LAMBDA ]] && LAMBDA=0
[[ -z $NSTATES ]] && NSTATES=1

OPTIONS="-b $BASIS -c $CHARGE -m $MULT -s $NSTATES"

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
  $RUNGMS $FILE > $FILE.out 2> $FILE.err && rm -rf $FILE.err
  [[ -f $TMPDIR/$FILE.dat ]] && mv $TMPDIR/$FILE.dat .
}


function init_qp()
{
  d=$1
  qp_edit -c $d
  echo $S2EIG > $d/determinants/s2_eig
  echo $NSTATES > $d/determinants/n_states
  echo $NSTATES_DIAG > $d/davidson/n_states_diag
  echo $PT2MAX > $d/perturbation/pt2_max
  echo $NDETMAX > $d/determinants/n_det_max
  echo $GENERATORS > $d/determinants/threshold_generators
  echo $SELECTORS > $d/determinants/threshold_selectors
  echo $THRESH_DAVIDSON > $d/davidson/threshold_davidson
  echo $LAMBDA > $d/mrcepa0/lambda_type
}

function run_fci ()
{
  d=$1                   ; shift
  GENERATORS=${1:-0.999} ; shift
  SELECTORS=${1:-0.9999} ; shift
  NDETMAX=${1:-524288}   ; shift
  NDETMAX_IN=$NDETMAX

  EZFIO=$d.fci
  rm -rf $EZFIO
  cp -r $d $EZFIO
  qp_set_frozen_core.py $EZFIO > /dev/null
  NDETMAX=262144
  init_qp $EZFIO
  echo F > $EZFIO/perturbation/do_pt2_end
  qp_run fci_zmq $EZFIO > $EZFIO.out
  qp_run save_natorb $EZFIO >> $EZFIO.out
  echo " [  FCI natorb  ] [ $EZFIO ]"
  NDETMAX=$NDETMAX_IN
  init_qp $EZFIO
  echo T > $EZFIO/perturbation/do_pt2_end
  qp_run fci_zmq $EZFIO >> $EZFIO.out
}

function run_fci_nonatorb ()
{
  d=$1                   ; shift
  GENERATORS=${1:-0.999} ; shift
  SELECTORS=${1:-0.9999} ; shift
  NDETMAX=${1:-524288}   ; shift

  EZFIO=$d.fci
  rm -rf $EZFIO
  cp -r $d $EZFIO
  qp_set_frozen_core.py $EZFIO > /dev/null
  init_qp $EZFIO
  echo T > $EZFIO/perturbation/do_pt2_end
  qp_run fci_zmq $EZFIO > $EZFIO.out
}

function run_cas_qp ()
{
  d=$1                   ; shift
  GENERATORS=${1:-0.999} ; shift
  SELECTORS=${1:-0.9999} ; shift
  NDETMAX=${1:-524288}   ; shift

  EZFIO=$d.cas
  rm -rf $EZFIO
  cp -r $d $EZFIO
  NMCC=$(grep NMCC $d.inp | cut -d '=' -f 2)
  NDOC=$(grep NDOC $d.inp | cut -d '=' -f 2)
  NALP=$(grep NALP $d.inp | cut -d '=' -f 2)
  NVAL=$(grep NVAL $d.inp | cut -d '=' -f 2)
  NCORE=$(qp_set_frozen_core.py $EZFIO -q)
  MO_TOT_NUM=$(($(cat $EZFIO/mo_basis/mo_tot_num)))
  qp_edit -c $EZFIO
  if [[ $NCORE -eq 0 ]] 
  then
    echo qp_set_mo_class $EZFIO -core "[1-$NMCC]" -act "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" -del "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
    qp_set_mo_class $EZFIO -core "[1-$NMCC]" -act "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" -del "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
  else
    echo qp_set_mo_class $EZFIO -core "[1-$NMCC]" -act "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" -del "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" 
    qp_set_mo_class $EZFIO -core "[1-$NMCC]" -act "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" -del "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
  fi
  init_qp $EZFIO
  echo " [    CAS       ] [ $EZFIO ]"
  qp_run fci_zmq $EZFIO > $EZFIO.out
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
  if [[ $NCORE -eq 0 ]] 
  then
    echo qp_set_mo_class $EZFIO -inact "[1-$NMCC]" -act "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" -virt "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
    qp_set_mo_class $EZFIO -inact "[1-$NMCC]" -act "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" -virt "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
  else
    echo qp_set_mo_class $EZFIO -core "[1-$NCORE]" -inact "[$((NCORE+1))-$NMCC]" -act "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" -virt "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" 
    qp_set_mo_class $EZFIO -core "[1-$NCORE]" -inact "[$((NCORE+1))-$NMCC]" -act "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" -virt "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
  fi
  init_qp $EZFIO
  echo " [    CAS+SD    ] [ $EZFIO ]"
  qp_run cassd_zmq $EZFIO > $EZFIO.out
#  qp_run cas_sd_selected $EZFIO > $EZFIO.out
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
  init_qp $EZFIO
  echo " [    MRCCSD    ] [ $EZFIO ]"
  qp_run mrcc $EZFIO > $EZFIO.out
}

function run_mrsc2 ()
{
  d=$1                   ; shift
  LAMBDA=${1:-0}         ; shift
  GENERATORS=${1:-0.999} ; shift
  SELECTORS=${1:-0.9999} ; shift
  NDETMAX=${1:-524288}   ; shift

  EZFIO=$d.mrsc2
  rm -rf $EZFIO
  cp -r $d.cassd $EZFIO
  echo T > $EZFIO/determinants/read_wf
  echo T > $EZFIO/perturbation/do_pt2_end
  init_qp $EZFIO
  echo " [    MRSC2     ] [ $EZFIO ]"
  qp_run mrsc2 $EZFIO > $EZFIO.out
}

function run_mrcepa ()
{
  d=$1                   ; shift
  LAMBDA=${1:-0}         ; shift
  GENERATORS=${1:-0.999} ; shift
  SELECTORS=${1:-0.9999} ; shift
  NDETMAX=${1:-524288}   ; shift

  EZFIO=$d.mrcepa
  rm -rf $EZFIO
  cp -r $d.cassd $EZFIO
  echo T > $EZFIO/determinants/read_wf
  echo T > $EZFIO/perturbation/do_pt2_end
  init_qp $EZFIO
  echo " [    MRCEPA    ] [ $EZFIO ]"
  qp_run mrcepa0 $EZFIO > $EZFIO.out
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
  print_geometry | create_gamess_input $OPTIONS $@ > ${d}.inp
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
  qp_set_frozen_core.py $1 > /dev/null
  qp_edit -c $1
  qp_run save_ortho_mos $1
  init_qp $1
}

function grep_CAS_energy ()
{
  if [[ $NSTATES == "1" ]]
  then
    LINE=$(awk " /TOTAL ENERGY =/ { print \"$1  \", \$4 \"  \"} " $1.out)
  else
    LINE=$(awk "/ STATE # .*  ENERGY =/ { print \"$1  \", \$6 \"  \"}" $1.out | tail -$NSTATES)
  fi
  echo " [      CAS     ] [ $LINE ]"
  echo $LINE >> data_CAS
  sort_file data_CAS
}

function get_energy ()
{
  if [[ $NSTATES == 1 ]] 
  then
    E=$(grep "E+PT2   " ${EZFIO}.out | tail -1 | awk '// { print   $3}')
    LINE=$(printf "%s  %16.10f\n" $1 $E)
  else
    E=$(grep "E+PT2   " ${EZFIO}.out | tail -1 | cut -d '=' -f 2)
    LINE=$(printf "%s  %s\n" $1 "$E")
  fi
}


function grep_FCI_energy ()
{
  EZFIO=$1.fci
  get_energy  $1
  echo " [      FCI     ] [ $LINE ]"
  echo $LINE >> data_FCI
  sort_file data_FCI
}

function grep_CAS_QP_energy ()
{
  EZFIO=$1.cas
  get_energy  $1
  echo " [    CAS       ] [ $LINE ]"
  echo $LINE >> data_CAS_QP
  sort_file data_CAS_QP
}

function grep_CASSD_energy ()
{
  EZFIO=$1.cassd
  get_energy  $1
  echo " [    CAS+SD    ] [ $LINE ]"
  echo $LINE >> data_CASSD
  sort_file data_CASSD
}

function grep_MRCC_energy ()
{
  EZFIO=$1.mrcc
  get_energy  $1
  echo " [    MRCCSD    ] [ $LINE ]"
  echo $LINE >> data_MRCC
  sort_file data_MRCC
}

function grep_MRCEPA_energy ()
{
  EZFIO=$1.mrcepa
  get_energy  $1
  echo " [    MRCEPA    ] [ $LINE ]"
  echo $LINE >> data_MRCEPA
  sort_file data_MRCEPA
}

function grep_MRSC2_energy ()
{
  EZFIO=$1.mrsc2
  get_energy  $1
  echo " [    MRSC2     ] [ $LINE ]"
  echo $LINE >> data_MRSC2
  sort_file data_MRSC2
}



# Force crash if the follownig functions are not defined
function update_z_variables ()
{
  echo update_z_variables function is not defined
  exit -1
}

function initialization ()
{
  echo initialization function is not defined
  exit -1
}

