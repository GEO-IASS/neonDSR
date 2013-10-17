#!/bin/bash

#DATA_PATH=/home/scidb/zproject/neonDSR/matlab

echo "Convert .csv to .scidb"
echo "----------------------------------------------------------------"

if [ -z "$1" ] 
then
  echo "Error calling script."
  echo "Usage: \$ scirpt file_name scdb_array_name"
fi

if [ -z "$2" ] 
then
  echo "Error calling script."
  echo "Usage: \$ scirpt scdb_array_name"
fi

DATA_PATH=$(dirname $1)
FILE_NAME=$(basename $1)
echo "$1 to .scidb"
time csv2scidb -s 1 -p NNNN < $1 > $DATA_PATH"/"$FILE_NAME".scidb"


echo "Remove $2_flat array from scidb"
iquery -aq "remove($2_flat);"

echo "Create $2_flat array"
time iquery -aq "create array $2_flat <x:int32, y:int32, wave_length:int32, val:int32> [i=0:*,1000000,0];"

echo "Load $DATA_PATH/$FILE_NAME.scidb to $2_flat array"
time iquery -anq "load($2_flat, '$DATA_PATH/$FILE_NAME.scidb');"

echo "Remove $2 array from scidb if exists"
iquery -aq "remove($2);"

X_MAX=$( cat $1 | cut -f1 -d "," | sort -nr | head -1)
Y_MAX=$( cat $1 | cut -f2 -d "," | sort -nr | head -1)
W_MAX=$( cat $1 | cut -f3 -d "," | sort -nr | head -1)
W_MIN=$(tail -n +2  $1  | cut -f3 -d "," | sort -n  | head -1)

CHUNK_SIZE=1000

echo "Create $2 array"
echo "create array $2 <val:int32> [x=0:$X_MAX,$CHUNK_SIZE,0, y=0:$Y_MAX,$CHUNK_SIZE,0, w=0:$W_MAX,$CHUNK_SIZE,0];"

time iquery -aq "create array $2 <val:int32> [x=0:$X_MAX,$CHUNK_SIZE,0, y=0:$Y_MAX,$CHUNK_SIZE,0, w=$W_MIN:$W_MAX,$CHUNK_SIZE,0];"

time iquery -aq "redimension_store($2_flat, $2)";

# Clean-up
iquery -aq "remove($2_flat);
