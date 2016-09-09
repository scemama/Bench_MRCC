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
  [[ -z $FILE ]] && exit 1

  # Check if TMPDIR is accessible
  if [[ -z $TMPDIR ]] 
  then
    echo "TMPDIR is not defined. Please define TMPDIR"
  fi
  mkdir -p ${TMPDIR}/gamess
  
  echo "[R] : [    GAMESS    ] [ $FILE ]"
  rm -f $TMPDIR/${FILE}.*
  $RUNGMS $FILE > $FILE.out 2> /dev/null
  [[ -f $TMPDIR/$FILE.dat ]] && mv $TMPDIR/$FILE.dat .
  echo "[D] : [    GAMESS    ] [ $FILE ]"
}

