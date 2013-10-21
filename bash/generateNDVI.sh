#!/bin/bash

echo "Convert an Hyper Spectral Image (HSI) 3D-array to it's Normalized Difference Vegetation Index (NDVI)."
echo "----------------------------------------------------------------"

if [ -z "$1" ] 
then
    echo "Error calling script."
    echo "Usage: \$ scirpt scdb_array_name"
    exit 0
fi

echo "Calculating NDVI values..."

time iquery -aq "
show(
 '   apply(
        join(
            attribute_rename(
                slice($1, w, 42),
                val,
                nir
            ),
            attribute_rename(
                slice($1, w, 37),
                val,
                red
            )
        ), 
        ndvi, (nir - red) / (nir + red) 
    )
','afl' )  
"


time iquery -aq "
show('
    redimension(
        project(
            apply(
                    join(
                        attribute_rename(
                            slice($1, w, 42),
                            val,
                            nir
                        ),
                        attribute_rename(
                            slice($1, w, 37),
                            val,
                            red
                        )
                    ), 
                    ndvi, (nir - red) / (nir + red) 
                )
        ,ndvi ),
        <x:int64,y:int64>[i=0:*,1,0])
', 'afl')
    "

