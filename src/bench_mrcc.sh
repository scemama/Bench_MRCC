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
[[ -z $S2EIG  ]] && S2EIG=1
[[ -z $PT2MAX ]] && PT2MAX=5.e-4
[[ -z $NSTATES ]] && NSTATES=1
[[ -z $NSTATES_DIAG ]] && NSTATES_DIAG=16
[[ -z $THRESH_DAVIDSON ]] && THRESH_DAVIDSON=1.e-12
[[ -z $NSTATES ]] && NSTATES=1
[[ -z $STATE_FOLLOWING ]] && STATE_FOLLOWING=0

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
  rm -f ${FILE}.dat
  $RUNGMS $FILE > $FILE.out 2> $FILE.err && rm -rf $FILE.err
  [[ -f $TMPDIR/$FILE.dat ]] && mv $TMPDIR/$FILE.dat .
}


function init_qp()
{
  d=$1
  qp set_file $1
  qp edit -c 
  qp set determinants s2_echg $S2EIG 
  qp set determinants n_states $NSTATES
  qp set determinants n_states_diag $NSTATES_DIAG
  qp set determinants n_det_max $NDETMAX
  qp set davidson threshold_davidson $THRESH_DAVIDSON
  qp set davidson state_following $STATE_FOLLOWING
  qp set perturbation pt2_max $PT2MAX
}

function run_fci ()
{
  d=$1                   ; shift
  NDETMAX=${1:-1000000}  ; shift
  NDETMAX_IN=$NDETMAX

  EZFIO=$d.fci
  rm -rf $EZFIO
  cp -r $d $EZFIO
  qp_set_frozen_core $EZFIO > /dev/null
  NDETMAX=262144
  init_qp $EZFIO
  echo F > $EZFIO/perturbation/do_pt2_end
  srun qp_run fci $EZFIO > $EZFIO.out
  srun qp_run save_natorb $EZFIO >> $EZFIO.out
  echo " [  FCI natorb  ] [ $EZFIO ]"
  NDETMAX=$NDETMAX_IN
  init_qp $EZFIO
  echo T > $EZFIO/perturbation/do_pt2_end
  srun qp_run fci $EZFIO >> $EZFIO.out
}

function run_fci_nonatorb ()
{
  d=$1                   ; shift
  NDETMAX=${1:-1000000}  ; shift

  EZFIO=$d.fci
  rm -rf $EZFIO
  cp -r $d $EZFIO
  qp_set_frozen_core $EZFIO > /dev/null
  init_qp $EZFIO
  srun qp_run fci $EZFIO > $EZFIO.out
}

function run_cas_qp ()
{
  d=$1                   ; shift
  NDETMAX=${1:-1000000}  ; shift

  EZFIO=$d
  NMCC=$(grep NMCC $d.inp | cut -d '=' -f 2)
  NDOC=$(grep NDOC $d.inp | cut -d '=' -f 2)
  NALP=$(grep NALP $d.inp | cut -d '=' -f 2)
  NVAL=$(grep NVAL $d.inp | cut -d '=' -f 2)
  NCORE=$(qp_set_frozen_core $EZFIO -q)
  MO_TOT_NUM=$(($(cat $EZFIO/mo_basis/mo_tot_num)))
  qp_edit -c $EZFIO
  if [[ $NCORE -eq 0 ]] 
  then
    echo qp_set_mo_class $EZFIO \
      -c "[1-$NMCC]" \
      -a "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" \
      -d "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
    qp_set_mo_class $EZFIO \
      -c "[1-$NMCC]" \
      -a "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" \
      -d "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
  else
    echo qp_set_mo_class $EZFIO \
      -c "[1-$NMCC]" \
      -a "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" \
      -d "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" 
    qp_set_mo_class $EZFIO \
      -c "[1-$NMCC]" \
      -a "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" \
      -d "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
  fi
  init_qp $EZFIO
  echo " [    CAS       ] [ $EZFIO ]"
  srun qp_run fci $EZFIO > $EZFIO.out || return
  echo T > ${EZFIO}/determinants/read_wf
  qp_set_frozen_core $EZFIO
}

function run_cassd ()
{
  d=$1                   ; shift
  NDETMAX=${1:-1000000}  ; shift

  EZFIO=$d.cassd
  rm -rf $EZFIO
  cp -r $d $EZFIO
  NMCC=$(grep NMCC $d.inp | cut -d '=' -f 2)
  NDOC=$(grep NDOC $d.inp | cut -d '=' -f 2)
  NALP=$(grep NALP $d.inp | cut -d '=' -f 2)
  NVAL=$(grep NVAL $d.inp | cut -d '=' -f 2)
  NCORE=$(qp_set_frozen_core $EZFIO -q)
  MO_TOT_NUM=$(($(cat $EZFIO/mo_basis/mo_tot_num)))
  qp_edit -c $EZFIO
  if [[ $NCORE -eq 0 ]] 
  then
    echo qp_set_mo_class $EZFIO \
      -i "[1-$NMCC]" \
      -a "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" \
      -v "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
    qp_set_mo_class $EZFIO \
      -i "[1-$NMCC]" \
      -a "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" \
      -v "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
  else
    echo qp_set_mo_class $EZFIO \
      -c "[1-$NCORE]" \
      -i "[$((NCORE+1))-$NMCC]" \
      -a "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" \
      -v "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" 
    qp_set_mo_class $EZFIO \
      -c "[1-$NCORE]" \
      -i "[$((NCORE+1))-$NMCC]" \
      -a "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" \
      -v "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
  fi
  init_qp $EZFIO
  echo " [    CAS+SD    ] [ $EZFIO ]"
  srun qp_run cassd_zmq $EZFIO > $EZFIO.out
#  srun qp_run cas_sd_selected $EZFIO > $EZFIO.out
}

function run_cis()
{
  d=$1                   ; shift
  NDETMAX=${1:-1000000}  ; shift

  EZFIO=$d.cis
  rm -rf $EZFIO
  cp -r $d $EZFIO
  NMCC=$(grep NMCC $d.inp | cut -d '=' -f 2)
  NDOC=$(grep NDOC $d.inp | cut -d '=' -f 2)
  NALP=$(grep NALP $d.inp | cut -d '=' -f 2)
  NVAL=$(grep NVAL $d.inp | cut -d '=' -f 2)
  NCORE=$(qp_set_frozen_core $EZFIO -q)
  MO_TOT_NUM=$(($(cat $EZFIO/mo_basis/mo_tot_num)))
  qp_edit -c $EZFIO
  if [[ $NCORE -eq 0 ]] 
  then
    echo qp_set_mo_class $EZFIO \
      -i "[1-$NMCC]" \
      -a "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" \
      -v "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
    qp_set_mo_class $EZFIO \
      -i "[1-$NMCC]" \
      -a "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" \
      -v "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
  else
    echo qp_set_mo_class $EZFIO \
      -c "[1-$NCORE]" \
      -i "[$((NCORE+1))-$NMCC]" \
      -a "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" \
      -v "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" 
    qp_set_mo_class $EZFIO \
      -c "[1-$NCORE]" \
      -i "[$((NCORE+1))-$NMCC]" \
      -a "[$((NMCC+1))-$((NMCC+NDOC+NVAL+NALP))]" \
      -v "[$((NMCC+NDOC+NVAL+NALP+1))-$MO_TOT_NUM]" > /dev/null
  fi
  init_qp $EZFIO
  echo " [    CIS       ] [ $EZFIO ]"
  srun qp_run cis $EZFIO > $EZFIO.out
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
  mv $d.out $d.gamess.out
}

function sort_file ()
{
  sort -n $1 > $1.tmp
  mv $1.tmp $1
}

function convert_to_qp ()
{
  echo " [  QP_CONVERT  ] [ $1 ]"
  qp_convert_output_to_ezfio ${1}.gamess.out -o $1
  qp_set_frozen_core $1 > /dev/null
  qp_edit -c $1
  init_qp $1
}

function grep_CAS_energy ()
{
  if [[ $NSTATES == "1" ]]
  then
    LINE=$(awk " /TOTAL ENERGY =/ { print \"$1  \", \$4 \"  \"} " $1.gamess.out)
  else
    LINE=$(awk "/ STATE # .*  ENERGY =/ { print \"$1  \", \$6 \"  \"}" $1.gamess.out | tail -$NSTATES)
  fi
  echo " [      CAS     ] [ $LINE ]"
  echo $LINE >> data_CAS
  sort_file data_CAS
}

function get_extrapolated_energy ()
{
  local OUT
  OUT=${EZFIO}.out
  if [[ $NSTATES == 1 ]] 
  then
    E1=$(grep -A 3 Extrapolated ${OUT} | tail -20 | tail -1)
    LINE=$(printf "%s  %s %s %s\n" $1 $E1)
  elif [[ $NSTATES == 2 ]]
  then
    E1=$(grep -A 3 Extrapolated ${OUT} | tail -20 | head -15 | tail -1)
    E2=$(grep -A 3 Extrapolated ${OUT} | tail -20 | tail -1)
    LINE=$(printf "%s  %s %s %s\n" $1 $E1 $E2)
  elif [[ $NSTATES == 3 ]]
  then
    E1=$(grep -A 3 Extrapolated ${OUT} | tail -20 | head -10 | tail -1)
    E2=$(grep -A 3 Extrapolated ${OUT} | tail -20 | head -15 | tail -1)
    E3=$(grep -A 3 Extrapolated ${OUT} | tail -20 | tail -1)
    LINE=$(printf "%s  %s %s %s\n" $1 $E1 $E2 $E3)
  fi
}


function grep_CIS_energy ()
{
  EZFIO=$1.fci
  qp set_file $EZFIO
  E=$(qp get cis energy | tr "," " " | tr "[" " "| tr "]" " ")
  LINE=$(printf "%s  %s\n" $1 $E)
  echo " [      CIS     ] [ $LINE ]"
  echo $LINE >> data_CIS
  sort_file data_CIS
}

function grep_FCI_energy ()
{
  EZFIO=$1.fci
  get_extrapolated_energy $1
  echo " [      FCI     ] [ $LINE ]"
  echo $LINE >> data_FCI
  sort_file data_FCI
}

function grep_CAS_QP_energy ()
{
  EZFIO=$1
  get_extrapolated_energy $1
  echo " [    CAS       ] [ $LINE ]"
  echo $LINE >> data_CAS_QP
  sort_file data_CAS_QP
}

function grep_CASSD_energy ()
{
  EZFIO=$1.cassd
  get_extrapolated_energy $1
  echo " [    CAS+SD    ] [ $LINE ]"
  echo $LINE >> data_CASSD
  sort_file data_CASSD
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

