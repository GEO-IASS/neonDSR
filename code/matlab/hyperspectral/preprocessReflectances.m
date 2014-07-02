function reflectances = preprocessReflectances( reflectances, smoothing_window_size )
% does the standard preprocessing on list of reflectances 

reflectances = removeWaterAbsorbtionBands( reflectances, 0);
% x = 1:size(reflectances,2); figure; plot(x,reflectances); 
reflectances = gaussianSmoothing(reflectances, smoothing_window_size);
% x = 1:size(reflectances,2); figure; plot(x,reflectances); 
for i = 1:size(reflectances, 1)
  reflectances(i,:) = scalePixel(reflectances(i,:));
end



end

