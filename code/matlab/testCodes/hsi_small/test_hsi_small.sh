#!/bin/bash

echo "Convert hsi_small.csv to .scidb"
csv2scidb -s 1 -p NNNN < hsi_small.csv > hsi_small.scidb

echo "Remove hsi_small_flat array from scidb"
iquery -aq "remove(hsi_small_flat);"

echo "Create hsi_small_flat array"
iquery -aq "create array hsi_small_flat <x:int32, y:int32, wave_length:int32, val:int32> [i=0:*,1000000,0];"

echo "Load hsi_small_flat.scidb to hsi_small_flat array"
iquery -anq "load(hsi_small_flat, '$PWD/hsi_small.scidb');"

echo "Remove hsi_small array from scidb if exists"
iquery -aq "remove(hsi_small);"

X_MAX=$( cat hsi_small.csv | cut -f1 -d "," | sort -nr | head -1)
Y_MAX=$( cat hsi_small.csv | cut -f2 -d "," | sort -nr | head -1)
W_MAX=$( cat hsi_small.csv | cut -f3 -d "," | sort -nr | head -1)
W_MIN=$(tail -n +2  hsi_small.csv  | cut -f3 -d "," | sort -n  | head -1)

echo "Create hsi_small array"
echo "create array hsi_small <val:int32> [x=0:$X_MAX,10,0, y=0:$Y_MAX,10,0, w=0:$W_MAX,10,0];"

iquery -aq "create array hsi_small <val:int32> [x=0:$X_MAX,10,0, y=0:$Y_MAX,10,0, w=0:$W_MAX,$W_MIN,0];"

iquery -aq "redimension_store(hsi_small_flat, hsi_small)";

