function Output = getHSIBands(I, wavelengthsToGet)
%this function will return the an image with the bands that are closest to
%the desired wavelengths
arrayOfWaves = [];
for i = 1:numel(wavelengthsToGet)
   [C,Index] = min( abs(I.info.wavelength - wavelengthsToGet(i)) );
   arrayOfWaves = [arrayOfWaves, Index];
end

Output = I.z(:,:,arrayOfWaves);
end