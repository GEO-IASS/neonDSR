function ImageClickCallback(obj,event, wavelengths_titles, hsi_img, hsi_figure, reflectance_figure)
%IMAGECLICKCALLBACK Summary of this function goes here
% figures passed to draw red line and draw reflectance diagram

  global setting
  
  a = get(gca, 'CurrentPoint');
  assignin('caller', 'x',  a(1) );
  assignin('caller', 'y',  a(2) ); 
  y_index = floor(a(1,1));
  x_index = floor(a(2,2));
  
  
  figure(hsi_figure);
  hold on
  plot(y_index,x_index,'r.','MarkerSize',20);
  
 figure(reflectance_figure);
 reflectance = reshape(hsi_img(x_index, y_index, :), 1,224);
 
 nir = double(reflectance(setting.NIR_INDEX));  
 red = double(reflectance(setting.RED_INDEX)); 
 ndvi = (nir-red)/(nir+red);
 fprintf('NIR: %f   --  RED: %f --- NDVI:%f\n',nir, red, ndvi);

 % wavelength = envi.info.wavelength';
  
  plot(wavelengths_titles, reflectance);  xlabel('Wavelength(nm)'); ylabel('Reflectance');
  title (sprintf('Reflectance-Wavelength'));
  set(gca,'YTick',[0:0.2:1])%max(reflectance)])
  set(gca,'XTick',[0:100:max(wavelengths_titles)]);
  grid on;
  
  set(reflectance_figure, 'Position', [100 100 900 400]);
end

