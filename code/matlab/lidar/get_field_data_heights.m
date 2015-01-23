function  get_field_data_heights( lidar_figure, heightMap, baseEasting, baseNorthing, binResolution , specie, reflectance, roi, northing, easting, flight)

DEBUG = 0;

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
        
        maxPixelHeight = getPixelHeightInNeighborhood(heightMap, baseEasting, baseNorthing, binResolution, roiEasting(j), roiNorthing(j), DEBUG)
        
        maxROIHeight = max([maxROIHeight, maxPixelHeight]);
        
        % Mark field data in lidar map
        markCoordinateLiDAR( lidar_figure, heightMap, baseEasting, baseNorthing,  binResolution, roiEasting(j), roiNorthing(j) );
        
    end
    
    status = sprintf('%d\t%s\t%0.2f',uniqueROIs(i), roiSpecie, maxROIHeight);
    disp(status);
end


end

