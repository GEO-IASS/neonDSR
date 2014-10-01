
addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/lidar/');
addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/io/');
addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/io/csvIO');


binResolution = 2; % bin side length in meters

tic
%lidar_file08 = '/cise/homes/msnia/neon/lidar/DL20100901_osbs_FL08_discrete_lidar_NEON-L1B/DL20100901_osbs_FL08_discrete_lidar_NEON-L1B.las';
%[baseEasting08, baseNorthing08, heightMap08]  = getHeightMap(lidar_file08, binResolution);
%lidar_file09 = '/cise/homes/msnia/neon/lidar/DL20100901_osbs_FL09_discrete_lidar_NEON-L1B/DL20100901_osbs_FL09_discrete_lidar_NEON-L1B.las';
%[baseEasting09, baseNorthing09, heightMap09] = getHeightMap(lidar_file09, binResolution);
%lidar_file10 = '/cise/homes/msnia/neon/lidar/DL20100901_osbs_FL10_discrete_lidar_NEON-L1B/DL20100901_osbs_FL10_discrete_lidar_NEON-L1B.las';
%[baseEasting10, baseNorthing10, heightMap10] = getHeightMap(lidar_file10, binResolution);

%lidar_file08h = '/cise/homes/msnia/neon/lidar/lastools_heights/DL20100901_osbs_FL08_discrete_lidar_NEON-L1B-height.las';
%[baseEasting08h, baseNorthing08h, heightMap08h]  = getHeightMap(lidar_file08h, binResolution);
%lidar_file09h = '/cise/homes/msnia/neon/lidar/lastools_heights/DL20100901_osbs_FL09_discrete_lidar_NEON-L1B-height.las';
%[baseEasting09h, baseNorthing09h, heightMap09h] = getHeightMap(lidar_file09h, binResolution);
%lidar_file10h = '/cise/homes/msnia/neon/lidar/lastools_heights/DL20100901_osbs_FL10_discrete_lidar_NEON-L1B-height.las';
%[baseEasting10h, baseNorthing10h, heightMap10h] = getHeightMap(lidar_file10h, binResolution);

% TODO - first convert las files to height in lastools: 
% >lasheight.exe -i ..\..\DL20100901_osbs_FL10_discrete_lidar_NEON-L1B\DL20100901_osbs_FL10_discrete_lidar_NEON-L1B.las -replace_z -o height_lidar.las    

lidar_file_merge = '/cise/homes/msnia/neon/lidar/lastools_heights/merge_lidar_8_9_10-height.las';
[baseEasting_merge, baseNorthing_merge, heightMap_merge] =  getHeightMap(lidar_file_merge, binResolution);
toc


[ specie, reflectance, roi, northing, easting, flight ] = get_field_pixels();

uniqueROIs = unique(roi);
for i = 1 : numel(uniqueROIs)
    
   % For each ROI determine height:
   % Extract each ROI
   index = roi == uniqueROIs(i);
   roiSpecie = specie(index);
   roiSpecie = roiSpecie(1); % A single specie in each ROI
   roiReflectance = reflectance(index);
   roiNorthing = northing(index);
   roiEasting = easting(index);
   roiFlight = flight(index); % A single flight for each ROI
   roiFlight = roiFlight(1);
   maxROIHeight = -inf;
   
   for j = 1 : numel(roiNorthing)
      
      % Assuming that a pixel might be captured in its actual flight and/or
      % two adjacent flights.
      pixelHeight = getHeight( heightMap_merge, baseEasting_merge, baseNorthing_merge, binResolution, roiEasting(j), roiNorthing(j) );
      
      maxROIHeight = max([maxROIHeight, pixelHeight]);         
   end
   
   
   disp(['ROI: ', uniqueROIs(i), roiSpecie, maxROIHeight])
   
end



