#!/bin/bash

#DATA_PATH=/home/scidb/zproject/neonDSR/matlab

if [ -z "$1" ] 
then
  echo "Error calling script."
  echo "Usage: \$ scirpt csv_file_name scdb_array_name"
  exit 0
fi

if [ -z "$2" ] 
then
  echo "Error calling script."
  echo "Usage: \$ scirpt csv_file_name scdb_array_name"
  exit 0
fi

echo $1 $2 >> loadIndexedCSV.log

ABSOLUTE_PATH=$(cd $(dirname $1); pwd)/$(basename $1)
DATA_PATH=$(dirname $ABSOLUTE_PATH)
BASE_NAME=$(basename $ABSOLUTE_PATH)
# Use regrex to remove extension from file name 
# http://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
FILE_NAME="${BASE_NAME%%.*}" 

echo "Convert $1 to $FILE_NAME.scidb"
echo "----------------------------------------------------------------"

time csv2scidb -s 1 -p NNNN < $1 > $DATA_PATH"/"$FILE_NAME".scidb"


echo "Remove $2_flat array from scidb"
iquery -aq "remove($2_flat);"

echo "Create $2_flat array"
time iquery -aq "create array $2_flat <x:int64, y:int64, wave_length:int32, val:int32> [i=0:*,1000000,0];"

echo "Load $DATA_PATH/$FILE_NAME.scidb to $2_flat arra
y"
time iquery -anq "load($2_flat, '$DATA_PATH/$FILE_NAME.scidb');"

echo "Remove $2 array from scidb if exists"
iquery -aq "remove($2);"

echo "Extracting range of X, Y, W"
X_MAX=$( cat $1 | cut -f1 -d "," | sort -nr | head -1)
Y_MAX=$( cat $1 | cut -f2 -d "," | sort -nr | head -1)
W_MAX=$( cat $1 | cut -f3 -d "," | sort -nr | head -1)
W_MIN=$(tail -n +2  $1  | cut -f3 -d "," | sort -n  | head -1)

CHUNK_SIZE=1000

echo "Create $2 array"
echo "create array $2 <val:int32> [x=0:$X_MAX,$CHUNK_SIZE,0, y=0:$Y_MAX,$CHUNK_SIZE,0, w=0:$W_MAX,$CHUNK_SIZE,0];"

# TODO: make sure indexing should not start from 1 or remove 1 from max.
time iquery -aq "create array $2 <val:int32> [x=0:$X_MAX,$CHUNK_SIZE,0, y=0:$Y_MAX,$CHUNK_SIZE,0, w=$W_MIN:$W_MAX,$CHUNK_SIZE,0];"

echo "redimension_store"

time iquery -anq "redimension_store($2_flat, $2)";

# Clean-up
iquery -aq "remove($2_flat)";

