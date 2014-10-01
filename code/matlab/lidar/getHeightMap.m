function [baseEasting, baseNorthing, heightMap] = getHeightMap( lidar_file, bin_resolution )

% Neighbiors to Consider for subtraction to get height
radius = 2;


%disp(['Time: ' datestr(now, 'HH:MM:SS')])

%lidar_file = '/cise/homes/msnia/neon/lidar/DL20100901_osbs_FL08_discrete_lidar_NEON-L1B/DL20100901_osbs_FL08_discrete_lidar_NEON-L1B.las';
%bin_resolution = 3;
 



params = 'xyz'; % 'A'
[s, h, v] = lasread(lidar_file, params);

% remove outlier elevations
zmean= mean(s.Z); 
zstd = std(s.Z);
STD_STEPS_TO_MEAN = 2;
nonoutlier_elevations_indexes = s.Z <(zmean + STD_STEPS_TO_MEAN * zstd);
s.Z = s.Z(nonoutlier_elevations_indexes);
s.X = s.X(nonoutlier_elevations_indexes);
s.Y = s.Y(nonoutlier_elevations_indexes);

nonoutlier_elevations_indexes = s.Z >(zmean - STD_STEPS_TO_MEAN * zstd);
s.Z = s.Z(nonoutlier_elevations_indexes);
s.X = s.X(nonoutlier_elevations_indexes);
s.Y = s.Y(nonoutlier_elevations_indexes);

nonoutlier_elevations_indexes = s.Z > 0; % discard negative ones
s.Z = s.Z(nonoutlier_elevations_indexes);
s.X = s.X(nonoutlier_elevations_indexes);
s.Y = s.Y(nonoutlier_elevations_indexes);

nonoutlier_elevations_indexes = s.Z < 40; % discard anything more than 40
s.Z = s.Z(nonoutlier_elevations_indexes);
s.X = s.X(nonoutlier_elevations_indexes);
s.Y = s.Y(nonoutlier_elevations_indexes);

% display raw histogram and map--- %disp(['Time: ' datestr(now, 'HH:MM:SS')])
figure, hist(s.Z, 40), title('Elevation Histogram') , grid on
lasview(lastrim(s,50000),'z'); title('lasview scatter3 point cloud')

%lidar bining
[baseEasting, baseNorthing, Zmap] = lidarBining(s, bin_resolution);

% display binned histogram and map
figure, hist(Zmap(:), 40), title('Gridded Elevation Histogram') , grid on
figure, imagesc(flipud(Zmap));  title('Gridded Elevation Map')

% convert to height
heightMap = lidarElevationToHeight(Zmap, radius);
hm = heightMap(:);

%% TODO: keep both a max filter and min filter of lidar points. when getting height consider 
% all neighbor mins rather than max of mins of neighbors.

%once this is done, write a function that given a x,y returns height of its cell

%%
% display height histogram and map
figure, hist(hm(hm > 2), 40),  title('Height Histogram'), grid on
figure, imagesc(flipud(heightMap));  title('Gridded Height Map')
sum(isnan(heightMap(:)))   % -xyz 13506006x1 double   -A 13512407x1 double


% takes 10 miutes to draw contour
%step = 150;
%x=linspace(min(s.X),max(s.X),step);
%y=linspace(min(s.Y),max(s.Y),step);
%[X,Y]=meshgrid(x,y);
%F=TriScatteredInterp(s.X,s.Y,s.Z-1);
%contourf(X,Y,F(X,Y),100,'LineColor','none');

end

