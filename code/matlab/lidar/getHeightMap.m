function [baseX, baseY, heightMap] = getHeightMap( lidar_file, bin_resolution )



%disp(['Time: ' datestr(now, 'HH:MM:SS')])
%addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/lidar/');
%lidar_file = ;
%params = 'xyz'; [s, h, v] = lasread('/cise/homes/msnia/neon/lidar/DL20100901_osbs_FL09_discrete_lidar_NEON-L1B/DL20100901_osbs_FL09_discrete_lidar_NEON-L1B.las', params);
%min(s.X)
%max(s.X)
%min(s.Y)
%max(s.Y)
 
params = 'xyz'; % 'A'
[s, h, v] = lasread(lidar_file, params);

% remove outlier elevations
zmean= mean(s.Z); 
zstd = std(s.Z);
nonoutlier_elevations_indexes = s.Z <zmean + 3 * zstd;
s.Z = s.Z(nonoutlier_elevations_indexes);
s.X = s.X(nonoutlier_elevations_indexes);
s.Y = s.Y(nonoutlier_elevations_indexes);

% display raw histogram and map--- %disp(['Time: ' datestr(now, 'HH:MM:SS')])
figure, hist(s.Z, 40), title('Elevation Histogram') , grid on
lasview(lastrim(s,50000),'z');

%lidar bining
[baseX, baseY, Zmap] = lidarBining(s, bin_resolution);

% display binned histogram and map
figure, hist(Zmap(:), 40), title('Binned Elevation Histogram') , grid on
figure, imagesc(flipud(Zmap));

% convert to height
radius = 3;
heightMap = lidarElevationToHeight(Zmap, radius);
hm = heightMap(:);

%% TODO: keep both a max filter and min filter of lidar points. when getting height consider 
% all neighbor mins rather than max of mins of neighbors.

%once this is done, write a function that given a x,y returns height of its cell

%%
% display height histogram and map
figure, hist(hm(hm > 2), 40),  title('Height Histogram'), grid on
figure, imagesc(flipud(heightMap));


% takes 10 miutes to draw contour
%step = 150;
%x=linspace(min(s.X),max(s.X),step);
%y=linspace(min(s.Y),max(s.Y),step);
%[X,Y]=meshgrid(x,y);
%F=TriScatteredInterp(s.X,s.Y,s.Z-1);
%contourf(X,Y,F(X,Y),100,'LineColor','none');

end

