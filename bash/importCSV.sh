#!/bin/bash
echo "This import assumes the data is in csv format one number per line."
echo "-------------------------------------------------------------------"



MAIN_FILE=/home/morteza/zproject/neon/envi/csvlist.csv
let WC=$(sudo wc -l $MAIN_FILE  | cut -d" " -f1 )  
WC=$(expr $WC - 1)
#((WC=$WC + 1 ))
let DIMENTION="WC/224 + 1"
echo "dimention: " $DIMENTION
#((DIMENSION=sqrt( (WC ) / 224 ) ))
calc=$(echo "sqrt ( $DIMENTION )" | bc) #bc is used to create the floor: convert float to integer 
echo "VALUE: " $WC  " _ "  $DIMENTION " _ " $calc

let zeroBasedDim="$calc-1" 

CSV_FILE=csvlist_$WC.csv 
DIR=/home/scidb/temp/

echo "Copy to: "$DIR$CSV_FILE 
sudo cp $MAIN_FILE $DIR$CSV_FILE
sudo chgrp scidb $DIR$CSV_FILE
sudo chown scidb $DIR$CSV_FILE



echo "Convert to scidb format."
csv2scidb -p N < $DIR$CSV_FILE > $DIR"csvlist_"$WC".scidb"

echo "remove(subimg_flat_$WC);"
iquery -aq "remove(subimg_flat_$WC);"

QUERY="CREATE ARRAY subimg_flat_$WC <val:int32>[i=0:$WC,1,0];"
echo $QUERY
iquery -aq "$QUERY"
echo "List arrays:"
iquery -aq "list('arrays')"

echo "Load..."
iquery -aq "load(subimg_flat_$WC, '/home/scidb/temp/csvlist_$WC.scidb')"

echo "Create reshaped matrix "  
#iquery -aq "CREATE ARRAY subimg_$WC <val:int32>[i=0:$zeroBasedDim,1,0, j=0:$zeroBasedDim,1,0, k=0:223,1,0];"

#iquery -aq "store(reshape(subimg_flat_$WC, subimg_$WC), subimg_$WC);"


