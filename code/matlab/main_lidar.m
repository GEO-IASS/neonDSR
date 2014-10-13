

init();
global setting;

addpath(strcat(setting.PREFIX, '/neonDSR/code/matlab/lidar/'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/io/'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/io/csvIO'));

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

[baseEasting_merge, baseNorthing_merge, heightMap_merge] =  getHeightMap(setting.LIDAR_FILE, binResolution);
toc

[ specie, reflectance, roi, northing, easting, flight ] = get_field_pixels();


lidar_figure = figure; imagesc(heightMap_merge);  title('Gridded Elevation Map'); colormap(gray);



get_field_data_heights(lidar_figure, heightMap_merge, baseEasting_merge, baseNorthing_merge, binResolution, specie, reflectance, roi, northing, easting, flight );

% TODO: Act on lidar data pixelated and aligned wth field data.

