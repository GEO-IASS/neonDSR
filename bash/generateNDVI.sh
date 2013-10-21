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

# I'm adding a new attribute to move x,y from dimension as attributes and sort for printing purposes to be in order
# I can't add an attribute, hence I add new dimension

time iquery -aq "

        
            
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
            
            
            

    "
#
