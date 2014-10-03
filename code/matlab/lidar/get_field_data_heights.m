function [ output_args ] = get_field_data_heights( heightMap, baseEasting, baseNorthing, binResolution )
%GET_FIELD_DATA_HEIGHTS Summary of this function goes here
%   Detailed explanation goes here



[ specie, reflectance, roi, northing, easting, flight ] = get_field_pixels();

uniqueROIs = unique(roi);
for i = 1 : numel(uniqueROIs)
    
   % For each ROI determine height:
   % Extract each ROI
   index = roi == uniqueROIs(i);
   roiSpecie = specie(index);
   roiSpecie = roiSpecie(1); % A single specie in each ROI
   roiSpecie = roiSpecie{1};
   roiReflectance = reflectance(index);
   roiNorthing = northing(index);
   roiEasting = easting(index);
   roiFlight = flight(index); % A single flight for each ROI
   roiFlight = roiFlight(1);
   maxROIHeight = -inf;
   
   for j = 1 : numel(roiNorthing)
      
      % Assuming that a pixel might be captured in its actual flight and/or
      % two adjacent flights.
      pixelHeight = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j), roiNorthing(j) );
      
      maxROIHeight = max([maxROIHeight, pixelHeight]);         
   end
   
   status = sprintf('%d\t%s\t%0.2f',uniqueROIs(i), roiSpecie, maxROIHeight);
   disp(status);
end


end

