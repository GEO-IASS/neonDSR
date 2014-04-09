function [ ndvi ] = NDVI( img )
%NDVI Summary of this function goes here
%   Detailed explanation goes here
global setting 

nir = double(img(:,:,setting.NIR_INDEX));  
red = double(img(:,:,setting.RED_INDEX)); 

ndvi_numerator = nir - red;
ndvi_denominator = nir + red;
ndvi =  ndvi_numerator ./ ndvi_denominator;

end

