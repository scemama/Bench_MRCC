#!/bin/bash


case "$1" in
    fci)
      for i in *.fci.out ; do awk "/PT2      =/ { printf \"%f\n\", \$3}" $i | tail -1 ; done | sort -n -k 3
      ;;
    mrsc2)
      ;;
    mrcepa)
      ;;
    mrcc)
      for i in  *.mrcc.out ; do awk "/ PT2/ { printf \"%f\n\", \$3}" $i | tail -1 ; done | sort -n -k 3
      ;;
    cassd)
      for i in  *.cassd.out ; do awk "/ PT2/ { printf \"%f\n\", \$3}" $i | tail -1 ; done | sort -n -k 3
      ;;
esac
