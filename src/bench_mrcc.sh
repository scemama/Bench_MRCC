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

[[ -z $MULT ]] && MULT=1
[[ -z $CHARGE ]] && CHARGE=0

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
  
  echo "[R] : [    GAMESS    ] [ $FILE ]"
  rm -f $TMPDIR/${FILE}.*
  $RUNGMS $FILE > $FILE.out 2> $FILE.err
  [[ -f $TMPDIR/$FILE.dat ]] && mv $TMPDIR/$FILE.dat .
  echo "[D] : [    GAMESS    ] [ $FILE ]"
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

function run_point ()
{ 
  d=$1
  shift
  update_z_variables $d
  print_geometry | create_gamess_input $OPTIONS $@ > $d.inp
  run_gamess $d
}



