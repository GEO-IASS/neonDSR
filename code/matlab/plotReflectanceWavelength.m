function plotReflectanceWavelength(reflectance_figure, reflectance, wavelength, message, toSave )
%% Plot reflectance vs Wavelength

  figure(reflectance_figure);
  plot(wavelength, reflectance);  
  xlabel('Wavelength(nm)'); ylabel('Reflectance');
  title (message);
  set(gca,'YTick',[0:0.1:max(reflectance)])
  set(gca,'XTick',[0:0.1:max(wavelength)])
  grid on;
  
  file = sprintf(strcat( message, '.','png'));
  if toSave
    saveas(reflectance_figure, file);
  end
  set(reflectance_figure, 'Position', [100 100 900 400])

end

