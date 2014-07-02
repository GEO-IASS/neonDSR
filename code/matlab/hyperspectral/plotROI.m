function plotROI( hsi_figure, envi, roi_index )
% Load ROIs and display them in actual image + plot its reflectances

path = '/cise/homes/msnia/zproject/neonDSR/docs/field_trip_28022014/';

% ROI titles
fid = fopen(strcat(path, 'osbs_polygons_notes.csv'),'rt');
tmp = textscan(fid, '%s','delimiter','\n');
fclose(fid);
specie = tmp{1}(roi_index);
specie = strrep(specie, ',', ' ');

% reflectance values and coordinates
fileName = strcat(path, 'ROIs/roi', num2str(roi_index), '.csv');
roi = csvread(fileName);
coordinates = roi(: , [4,5]);


r = roi(:, 8:231);
r(r < 0) = 0;
r(r > 10000) = 10000;
r = double(double(r) / 10000.1);
r = sqrt(double(r));

%tempfig = figure;
%for i=1:13
%     plotReflectanceWavelength( tempfig, reflectance(i, :), wavelength, sprintf('Reflectance-Wavelength intensity of ROI #%d %s',roi_index, specie{roi_index}), 0) 
%       hold on
%end
%  hold off


pointCount = size(roi,1);
reflectance_figure = figure;

wavelength = envi.info.wavelength';

for i=1:pointCount
  imageIndex = markCoordinate(hsi_figure, envi, coordinates(i,1),  coordinates(i,2) );
  
  reflectance = reshape(envi.z(imageIndex(2), imageIndex(1), :), 1,224);
  message = sprintf('ROI %s', specie{1});
  plotReflectanceWavelength( reflectance_figure, reflectance, wavelength, message, 1);
  diff = reflectance - r(i, :);
  %if diff >0
      disp(sprintf('%f',max(diff(:)))); 
  %end
 
  hold on
end
  hold off
end

