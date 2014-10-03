function pixel = scalePixel( pixelOriginal )
%% scale reflectance values
pixel = pixelOriginal;
pixel(pixel<0) = 0; % filter out negative noises
pixel(pixel >=10000) = NaN; % filter out large noises
pixel = double(double(pixel) / 10000.1);
pixel = sqrt(double(pixel));


end

