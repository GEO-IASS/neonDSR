function [ ndvi ] = NDVI( img )
%NDVI Summary of this function goes here
%   Detailed explanation goes here

nir = double(img(:,:,42));
red = double(img(:,:,37));

ndvi_numerator = nir - red;
ndvi_denominator = nir + red;
ndvi =  ndvi_numerator ./ ndvi_denominator;

end

