



addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/lidar/');
addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/io/');
addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/io/csvIO');


binResolution = 2; % bin side length in meters

tic
lidar_file08 = '/cise/homes/msnia/neon/lidar/DL20100901_osbs_FL08_discrete_lidar_NEON-L1B/DL20100901_osbs_FL08_discrete_lidar_NEON-L1B.las';
[baseX08, baseY08, heightMap08] = getHeightMap(lidar_file08, binResolution);
lidar_file09 = '/cise/homes/msnia/neon/lidar/DL20100901_osbs_FL09_discrete_lidar_NEON-L1B/DL20100901_osbs_FL09_discrete_lidar_NEON-L1B.las';
[baseX09, baseY09, heightMap09] = getHeightMap(lidar_file09, binResolution);
toc

targetX = 402536;
targetY = 3283512;

height08 = getHeight( heightMap08, baseX08, baseY08, binResolution, targetX, targetY );
height09 = getHeight( heightMap09, baseX09, baseY09, binResolution, targetX, targetY );
disp([height08 height09]);

targetX = 402536 + 2;
targetY = 3283512 + 2;

height08 = getHeight( heightMap08, baseX08, baseY08, binResolution, targetX, targetY );
height09 = getHeight( heightMap09, baseX09, baseY09, binResolution, targetX, targetY );
disp([height08 height09]);

targetX = 402536 + 2;
targetY = 3283512;

height08 = getHeight( heightMap08, baseX08, baseY08, binResolution, targetX, targetY );
height09 = getHeight( heightMap09, baseX09, baseY09, binResolution, targetX, targetY );
disp([height08 height09]);

targetX = 402536;
targetY = 3283512 + 2;

height08 = getHeight( heightMap08, baseX08, baseY08, binResolution, targetX, targetY );
height09 = getHeight( heightMap09, baseX09, baseY09, binResolution, targetX, targetY );
disp([height08 height09]);

targetX = 402536 -2;
targetY = 3283512 -2;

height08 = getHeight( heightMap08, baseX08, baseY08, binResolution, targetX, targetY );
height09 = getHeight( heightMap09, baseX09, baseY09, binResolution, targetX, targetY );
disp([height08 height09]);

targetX = 402536 -2;
targetY = 3283512;

height08 = getHeight( heightMap08, baseX08, baseY08, binResolution, targetX, targetY );
height09 = getHeight( heightMap09, baseX09, baseY09, binResolution, targetX, targetY );
disp([height08 height09]);

targetX = 402536 ;
targetY = 3283512 -2;

height08 = getHeight( heightMap08, baseX08, baseY08, binResolution, targetX, targetY );
height09 = getHeight( heightMap09, baseX09, baseY09, binResolution, targetX, targetY );
disp([height08 height09]);

% TODO: generate x and y's of each bin