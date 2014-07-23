function pixel = removeWaterAbsorbtionBands( pixel, set_nan )
%% Either completedly delete those bands or set them to NaN
% could be one pixel, a list of pixels, or a map of pixels
% envi.info.wavelength(105)
% envi.info.wavelength(120)
% envi.info.wavelength(151)
% envi.info.wavelength(171)
% envi.info.wavelength(215)
% envi.info.wavelength(224)

water_absorption_bands = [1:7 105:120 151:171 215:224];

if ndims(pixel) ==2 && size(pixel,1) == 1
    if set_nan == 1
        pixel(water_absorption_bands) = NaN;      
    else
        %cut nans
        %svm could not work with NaN, so we removed those columns instead of setting to NaN
        pixel(water_absorption_bands) = [];
    end
elseif ndims(pixel) == 2
    if set_nan == 1
        pixel(:,water_absorption_bands) = NaN;
    else
        %cut nans
        %svm could not work with NaN, so we removed those columns instead of setting to NaN
        pixel(:,water_absorption_bands) = [];
    end
elseif ndims(pixel) == 3
    if set_nan == 1
        pixel(:,:,water_absorption_bands) = NaN;
    else
        %cut nans
        %svm could not work with NaN, so we removed those columns instead of setting to NaN
        pixel(:,:,water_absorption_bands) = [];
    end
end

end

