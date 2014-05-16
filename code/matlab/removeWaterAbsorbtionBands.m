function pixel = removeWaterAbsorbtionBands( pixel, set_nan )
%% Either completedly delete those bands or set them to NaN
% could be one pixel, a list of pixels, or a map of pixels
if ndims(pixel) ==2 && size(pixel,1) == 1
    if set_nan == 1
        pixel(105:120) = NaN;
        pixel(151:171) = NaN;
        pixel(215:224) = NaN;
    else
        %cut nans
        %svm could not work with NaN, so we removed those columns instead of setting to NaN
        pixel(215:224) = [];
        pixel(151:171) = [];
        pixel(105:120) = [];
    end
elseif ndims(pixel) == 2
    if set_nan == 1
        pixel(:,105:120) = NaN;
        pixel(:,151:171) = NaN;
        pixel(:,215:224) = NaN;
    else
        %cut nans
        %svm could not work with NaN, so we removed those columns instead of setting to NaN
        pixel(:,215:224) = [];
        pixel(:,151:171) = [];
        pixel(:,105:120) = [];
    end
elseif ndims(pixel) == 3
    if set_nan == 1
        pixel(:,:,105:120) = NaN;
        pixel(:,:,151:171) = NaN;
        pixel(:,:,215:224) = NaN;
    else
        %cut nans
        %svm could not work with NaN, so we removed those columns instead of setting to NaN
        pixel(:,:,215:224) = [];
        pixel(:,:,151:171) = [];
        pixel(:,:,105:120) = [];
    end
end

end

