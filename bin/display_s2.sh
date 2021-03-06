#!/bin/bash


case "$1" in
    fci)
      for i in *.fci.out ; do awk "/S\^2 of state    1/ { printf \"%f : $i\n\",\$6}" $i | tail -1   ; done | sort -n
      ;;
    mrsc2)
      for i in *.mrsc2.out ; do awk "/S\^2 of state    1/ { printf \"%f : $i\n\",\$6}" $i | tail -1   ; done | sort -n
      ;;
    mrcepa)
      for i in *.mrcepa.out ; do awk "/S\^2 of state    1/ { printf \"%f : $i\n\",\$6}" $i | tail -1   ; done | sort -n
      ;;
    mrcc)
      for i in *.mrcc.out ; do awk "/S\^2 of state    1/ { printf \"%f : $i\n\",\$6}" $i | tail -1   ; done | sort -n
      ;;
    cassd)
      for i in *.cassd.out ; do awk "/S\^2 of state    1/ { printf \"%f : $i\n\",\$6}" $i | tail -1   ; done | sort -n
      ;;
esac
