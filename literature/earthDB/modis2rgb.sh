#!/bin/bash
platform=1
resolution=1
startLongitude_e4=-1280000
stopLongitude_e4=-980001
startLatitude_e4=150000
stopLatitude_e4=449999
startTime=201204111825
stopTime=201204111825

iquery -anq "remove(rgb)" > /dev/null 2>&1

attrs="<red:double null,green:double null,blue:double null>"
dims="[x=1:300000,15000,0,y=1:300000,15000,0]"
schema=$attrs$dims

iquery -anq "create immutable empty array rgb $schema" > /dev/null 2>&1

echo "Building RGB composite values..."

time iquery -anq "
    redimension_store(
        apply(
            between(
                join(
                    attribute_rename(
                        band_1_measurements,
                        reflectance,
                        red
                    ),
                    join(
                        attribute_rename(
                            band_4_measurements,
                            reflectance,
                            green
                        ),
                        attribute_rename(
                            band_3_measurements,
                            reflectance,
                            blue
                        )
                    )
                ),
                $startLongitude_e4, $startLatitude_e4, $startTime, $platform, $resolution,
                $stopLongitude_e4, $stopLatitude_e4, $stopTime, $platform, $resolution
            ), 
            x, longitude_e4 - $startLongitude_e4 + 1,
            y, latitude_e4 - $startLatitude_e4 + 1
        ), 
        rgb,
        avg(red) as red,
        avg(green) as green,
        avg(blue) as blue
    )
"

