%% resample cherry picker data to AVIRIS (224 bands)

fileData = csvread('/cise/homes/msnia/zproject/neonDSR/docs/NEON_Field_Data.csv');
wavelength = str2double(fileData(1,2:size(fileData,2))) * 10^-3;
species = fileData(2:size(fileData,1),1);
reflectance = str2double(fileData(2:size(fileData,1),2:size(fileData,2)));

resampled_reflectance = zeros(size(reflectance, 1), numel(envi.info.wavelength));
for i=1:size(reflectance, 1)
    resampled_reflectance(i,:) = resample(wavelength,reflectance(i,:), envi.info.wavelength');
end

reflectance_figure = figure;
plotReflectanceWavelength(reflectance_figure, resampled_reflectance, envi.info.wavelength', 's', 0 );
legend(strrep(species, '_', '\_'));

size(species)
size(resampled_reflectance)
data = [species num2cell(resampled_reflectance)];
cell2csv('/cise/homes/msnia/zproject/neonDSR/docs/NEON_Field_Data_Resampled.csv', data, ',');