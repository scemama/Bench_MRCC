#!/usr/bin/env python

import os, sys

datafiles = filter(lambda x: x.startswith('data_'), os.listdir(os.getcwd()))

# Read data files
data = {}
for file in datafiles:
  try:
    _, method, basis = file.split('_')
  except:
    pass
  else:
    with open(file,'r') as f:
      values_text = f.readlines()
      values = dict(map(lambda x: (float(x.split()[0]), float(x.split()[1])), values_text))
      if basis not in data:
        data[basis] = {}
      data[basis][method] = values

# Create data files
for basis in data:
  file = "NPE_%s"%basis
  try:
    keys = sorted(data[basis]['FCI'].keys())
  except:
    continue

  methods = sorted(filter(lambda x: x != "FCI", data[basis].keys()))
  with open(file,'w') as f:
    sum_ = {}
    minmax  = {}
    for m in methods:
      sum_[m] = 0.
      minmax[m] = (1.e30,-1.e30)
    line = "#%-7s "%"R"
    for m in methods:
      line += " %16s"%m
    print >>f, line
    for x in keys:
      cycle = False
      for m in methods:
        try:
          data[basis][m][x]
        except:
          cycle=True
          break
      if not cycle:
        line = "%-8f "%x
        EFCI = data[basis]['FCI'][x]
        for m in methods:
          delta_E = data[basis][m][x]-EFCI
          line += " %16f"%delta_E
          sum_[m] += delta_E
          minold, maxold = minmax[m]
          minmax[m] = (min(minold,delta_E), max(maxold,delta_E))
        print >>f, line
    line = "#Average " 
    for m in methods:
      line += " %16f"%(sum_[m]/len(keys))
    print >>f, line
    line = "#NPE     " 
    for m in methods:
      line += " %16f"%(minmax[m][1]-minmax[m][0])
    print >>f, line


for basis in data:
  methods = sorted(filter(lambda x: x != "FCI", data[basis].keys()))
  plots = []
  i=1
  for m in methods:
    i+=1
    plots.append("'NPE_%s' u 1:%d w lp title '%s'"%(basis,i,m))
  gnuplot_command = "plot "+", ".join(plots)
  print gnuplot_command
