% markCoordinate(hsi_figure, envi, 399523.000000000, 3286162.00000000 )
function [ imageindex ] = markCoordinate(hsi_figure, envi, XCoord, YCoord )
%MARKCOORDINATE marks the point with coordinate XCoord and YCoord in image
% as a red pixel, prints ERROR if the range is not proper.

  x_step_size = abs(envi.x(2) - envi.x(1));  
  y_step_size = abs(envi.y(2) - envi.y(1));
  
  x_index = -1;
  y_index = -1;
  % find index of the X coordinate
  for i=1:size(envi.x')
     if abs(envi.x(i) - XCoord) < x_step_size
         x_index = i;
     end
  end
  
    for i=1:size(envi.y')
     if abs(envi.y(i) - YCoord) < y_step_size
         y_index = i;
     end
  end
  
  if x_index == -1 || y_index == -1
     disp('Coordinates are out of bounds.') 
  end

  hold on
  figure(hsi_figure);

  plot(x_index,y_index,'r.','MarkerSize',20) 
  
  reflectance_figure = figure
  reflectance = reshape(envi.z(y_index, x_index, :), 1,224);
  wavelength = envi.info.wavelength';
  
  plot(wavelength, reflectance);  xlabel('Wavelength(nm)'); ylabel('Reflectance');
  title (sprintf('Reflectance-Wavelength intensity of Endmember #%d',i));
  set(gca,'YTick',[0:500:max(reflectance)])
  set(gca,'XTick',[0:100:max(wavelength)])
  grid on;
  
  set(reflectance_figure, 'Position', [100 100 900 400])

  imageindex= [x_index y_index];

  
  
  
end

