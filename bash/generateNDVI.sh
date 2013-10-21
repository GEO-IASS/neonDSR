#!/bin/bash

echo "Convert an Hyper Spectral Image (HSI) 3D-array to it's Normalized Difference Vegetation Index (NDVI)."
echo "----------------------------------------------------------------"

if [ -z "$1" ] 
then
    echo "Error calling script."
    echo "Usage: \$ scirpt scdb_array_name"
fi

echo "Calculating NDVI values..."

time iquery -aq "
apply(
    join(
        attribute_rename(
            slice(subimg, w, 42),
            val,
            nir
        ),
        attribute_rename(
            slice(subimg, w, 37),
            val,
            red
        )
    ), 
    ndvi, (nir - red) / (nir + red) 
)  
"

#time iquery -anq "
#between(
#    apply(
#        join(
#            attribute_rename(
#                subimg,val,val_a
#            ),
#            attribute_rename(
#                subimg,val,val_b
#            )
#        ),
#        ndvi, (val_a - val_b) / (val_a + val_b)
#     ),
#     0, 0, 42,

     

 
 #)
#"
