#!/bin/bash

DATA_PATH=/home/scidb/zproject/neonDSR/matlab

echo "Convert hsi_img.csv to .scidb"
csv2scidb -s 1 -p NNNN < $DATA_PATH"/hsi_img.csv" > $DATA_PATH"/hsi_img.scidb"


echo "Remove hsi_img_flat array from scidb"
iquery -aq "remove(hsi_img_flat);"

echo "Create hsi_img_img array"
iquery -aq "create array hsi_img_flat <x:int32, y:int32, wave_length:int32, val:int32> [i=0:*,1000000,0];"

echo "Load hsi_img_flat.scidb to hsi_img_flat array"
iquery -anq "load(hsi_img_flat, '$DATA_PATH/hsi_img.scidb');"

echo "Remove hsi_img array from scidb if exists"
iquery -aq "remove(hsi_img);"

X_MAX=$( cat $DATA_PATH"/hsi_img.csv" | cut -f1 -d "," | sort -nr | head -1)
Y_MAX=$( cat $DATA_PATH"/hsi_img.csv" | cut -f2 -d "," | sort -nr | head -1)
W_MAX=$( cat $DATA_PATH"/hsi_img.csv" | cut -f3 -d "," | sort -nr | head -1)
W_MIN=$(tail -n +2  $DATA_PATH"/hsi_img.csv"  | cut -f3 -d "," | sort -n  | head -1)

CHUNK_SIZE=1000

echo "Create hsi_img array"
echo "create array hsi_img <val:int32> [x=0:$X_MAX,$CHUNK_SIZE,0, y=0:$Y_MAX,$CHUNK_SIZE,0, w=0:$W_MAX,$CHUNK_SIZE,0];"

iquery -aq "create array hsi_img <val:int32> [x=0:$X_MAX,$CHUNK_SIZE,0, y=0:$Y_MAX,$CHUNK_SIZE,0, w=$W_MIN:$W_MAX,$CHUNK_SIZE,0];"

iquery -aq "redimension_store(hsi_img_flat, hsi_img)";

