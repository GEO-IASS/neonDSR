function [ output_args ] = plotROI( hsi_figure, roi_index )
%

fileName = strcat('/cise/homes/msnia/zproject/neonDSR/docs/field_trip_28022014/roi', num2str(roi_index), '.csv');
roi = csvread(fileName);
coordinates = roi(: , [4,5]);
pointCount = size(roi,1);
reflectance_figure = figure;
for i=1:pointCount
  imageIndex = markCoordinate(envi_figure, envi, coordinates(i,1),  coordinates(i,2) );
  
  reflectance = reshape(envi.z(imageIndex(2), imageIndex(1), :), 1,224);
  wavelength = envi.info.wavelength';
  
  figure(reflectance_figure);
  plot(wavelength, reflectance);  
  hold on
end
  hold off

  figure(reflectance_figure)
  xlabel('Wavelength(nm)'); ylabel('Reflectance');
  title (sprintf('Reflectance-Wavelength intensity of Endmember #%d',i));
  set(gca,'YTick',[0:0.1:max(reflectance)])
  set(gca,'XTick',[0:100:max(wavelength)])
  grid on;
  
  set(reflectance_figure, 'Position', [100 100 900 400])

end

