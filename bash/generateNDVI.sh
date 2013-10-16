#!/bin/bash

echo "Convert an Hyper Spectral Image (HSI) 3D-array to it's Normalized Difference Vegetation Index (NDVI)."
echo "----------------------------------------------------------------"

if [ -z "$1" ] 
then
    echo "Error calling script."
    echo "Usage: \$ scirpt scdb_array_name"
fi

echo "Calculating NDVI values..."

time iquery -anq "
    
"
