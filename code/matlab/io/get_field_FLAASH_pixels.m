function [ species, reflectances_flaash, rois, northings, eastings, flights ] = get_field_FLAASH_pixels(envi03, envi04, envi05)
%% As field data provided by Sarah Graves are in ATCOR atmospheric correction
% This function will retrieve the flaash atmospheric correction values.

[ species, reflectances, rois, northings, eastings, flights ] = get_field_ATCOR_pixels();

reflectances_flaash = reflectances;
for i=1:numel(species)
    if strcmp(flights(i), '3')
        envi = envi03;
    elseif  strcmp(flights(i), '4')
        envi = envi04;
    elseif  strcmp(flights(i), '5')
        envi = envi05;
    end
    
    x=0; y=0;
    for j=1:numel(envi.x')
        if envi.x(j) < eastings(j) && envi.x(j+1) > eastings(j)
            x = j;
        end
    end
    
    for j=1:numel(envi.y')
        if envi.y(j) < northings(j) && envi.y(j+1) > northings(j)
            y = j;
        end
    end
    reflectances_flaash(i) = envi(x,y,:);
end

end

