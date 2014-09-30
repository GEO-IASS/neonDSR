function [ species, reflectance ] = load_Spectral_library()
%LOAD_SPECTRAL_LIBRARY Summary of this function goes here
%   Detailed explanation goes here

global setting;

visualize = 0;

fileData = csvread(setting.SPECTRAL_LIBRARY);
wavelength = str2double(fileData(1,11:size(fileData,2))) * 10^-3;
species = fileData(2:size(fileData,1),1);
reflectance = str2double(fileData(2:size(fileData,1),11:size(fileData,2)));
reflectance = removeWaterAbsorbtionBands( reflectance, 0);

for i=1:size(reflectance, 1)
    for j=1:size(reflectance, 2)
        if isnan(reflectance(i,j))
            reflectance(i,j) = (reflectance(i,j - 1) + reflectance(i,j + 1)) / 2;
        end
    end
end

if visualize
    reflectance_figure = figure;
    plotReflectanceWavelength(reflectance_figure, reflectance(1:38,:), wavelength, 's', 0 );
    legend(strrep(species(1:38), '_', '\_'), 'Location', 'EastOutside');
    
    
    reflectance_figure = figure;
    plotReflectanceWavelength(reflectance_figure, reflectance(39:size(reflectance,1),:), wavelength, 's', 0 );
    legend(strrep(species(39:size(reflectance,1)), '_', '\_'), 'Location', 'EastOutside');
end


end

