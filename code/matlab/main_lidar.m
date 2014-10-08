
addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/lidar/');
addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/io/');
addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/io/csvIO');
init();

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

%  first convert las files to height in lastools: 
% >lasheight.exe -i ..\..\DL20100901_osbs_FL10_discrete_lidar_NEON-L1B\DL20100901_osbs_FL10_discrete_lidar_NEON-L1B.las -replace_z -o height_lidar.las    

lidar_file_merge = '/cise/homes/msnia/neon/lidar/lastools_heights/merge_lidar_7_8_9_10_13_14-height.las';
[baseEasting_merge, baseNorthing_merge, heightMap_merge] =  getHeightMap(lidar_file_merge, binResolution);
toc

[ specie, reflectance, roi, northing, easting, flight ] = get_field_pixels();


lidar_figure = figure; imagesc(heightMap_merge);  title('Gridded Elevation Map'); colormap(gray);



get_field_data_heights(lidar_figure, heightMap_merge, baseEasting_merge, baseNorthing_merge, binResolution, specie, reflectance, roi, northing, easting, flight );

% TODO: Act on lidar data pixelated and aligned wth field data.

