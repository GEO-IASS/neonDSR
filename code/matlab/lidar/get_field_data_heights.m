function  get_field_data_heights( lidar_figure, heightMap, baseEasting, baseNorthing, binResolution , specie, reflectance, roi, northing, easting, flight)



DEBUG = 1;

uniqueROIs = unique(roi);

for i = 1 : 1% numel(uniqueROIs)
    
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
      pixelHeight = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j), roiNorthing(j), DEBUG );
      disp([ roiEasting(j), roiNorthing(j), pixelHeight]);
      
      p0   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) - binResolution, roiNorthing(j) - binResolution, DEBUG);
      p1   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) - binResolution, roiNorthing(j), DEBUG);
      p2   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j), roiNorthing(j) - binResolution, DEBUG);
      p3   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) + binResolution, roiNorthing(j) + binResolution, DEBUG);
      p4   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) + binResolution, roiNorthing(j) , DEBUG);
      p5   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j), roiNorthing(j) + binResolution, DEBUG);
      p6   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) - binResolution, roiNorthing(j) + binResolution, DEBUG);
      p7   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) + binResolution, roiNorthing(j) - binResolution, DEBUG);
     
      p20   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) - 2 * binResolution, roiNorthing(j) - 2 * binResolution, DEBUG);
      p21   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) - 2 * binResolution, roiNorthing(j), DEBUG);
      p22   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j), roiNorthing(j) - 2 * binResolution, DEBUG);
      p23   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) + 2 * binResolution, roiNorthing(j) + 2 * binResolution, DEBUG);
      p24   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) + 2 * binResolution, roiNorthing(j) , DEBUG);
      p25   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j), roiNorthing(j) + 2 * binResolution, DEBUG);
      p26   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) - 2 * binResolution, roiNorthing(j) + 2 *  binResolution, DEBUG);
      p27   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) + 2 * binResolution, roiNorthing(j) - 2 * binResolution, DEBUG);
       
      p28   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) + binResolution, roiNorthing(j) + 2 * binResolution, DEBUG);
      p29   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) - binResolution, roiNorthing(j) + 2 *  binResolution, DEBUG);
      p30   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) + 2 * binResolution, roiNorthing(j) - binResolution, DEBUG);
      p31   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) + 2 * binResolution, roiNorthing(j) + binResolution, DEBUG);
      
      p32   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) + binResolution, roiNorthing(j) - 2 * binResolution, DEBUG);
      p33   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) - binResolution, roiNorthing(j) - 2 *  binResolution, DEBUG);
      p34   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) - 2 * binResolution, roiNorthing(j) - binResolution, DEBUG);
      p35   = getHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j) - 2 * binResolution, roiNorthing(j) + binResolution, DEBUG);
      
      max_neighbor_height = max([p0, p1, p2, p3, p4, p5, p6, p7, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35]);
      
      % Mark field data in lidar map
      markCoordinateLiDAR( lidar_figure, heightMap, baseEasting, baseNorthing,  binResolution, roiEasting(j), roiNorthing(j) );
      
      maxROIHeight = max([maxROIHeight, pixelHeight, max_neighbor_height]);         
   end
 %  uniq_roi_specie(i) = roiSpecie;
 %  uniq_roi_height(i) = maxROIHeight;
   
   status = sprintf('%d\t%s\t%0.2f',uniqueROIs(i), roiSpecie, maxROIHeight);
   disp(status);
end


end

