%% Main runner of all sections
% generic normalization - not suitable for hyperspectral data
%envi.z = double((envi.z - min_num)) / double((max_num - min_num)); % scale envi.z

cd('/cise/homes/msnia/zproject/neonDSR/code/matlab');
addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/hyperspectral');
addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/io');


init();
global setting;

% TODO I need a random index generator per crowns (for each specie there is
% a certain number of crowns available. 
% if I want to do 90-10 on train-test I have to do 90-10 on each specie
% crowns



envi03 = load_flight_image('/cise/homes/msnia/neon/morning/f100904t01p00r03rdn_b_sc01_ort_flaashreflectance_img');
envi03.z = removeWaterAbsorbtionBands(envi03.z, 0);
[~, envi03_figure, envi03_h] = toRGB(envi03.z, 'Flight 03'); 

envi04 = load_flight_image('/cise/homes/msnia/neon/morning//f100904t01p00r04rdn_b_sc01_ort_flaashreflectance_img');
envi04.z = removeWaterAbsorbtionBands(envi04.z, 0);
[~, envi04_figure, envi04_h] = toRGB(envi04.z, 'Flight 04'); 

envi05 = load_flight_image('/cise/homes/msnia/neon/morning/f100904t01p00r05rdn_b_sc01_ort_flaashreflectance_img');
envi05.z = removeWaterAbsorbtionBands(envi05.z, 0);
[~, envi05_figure, envi05_h] = toRGB(envi02.z, 'Flight 05'); 

% TODO : mark field samples on hyperspectral and lidar flights.
% TODO : BBL is the good/bad bands
envi = envi02;
subimg = envi.z;

%% NDVI Filter Clouds and Shaddows

ndvi = toNDVI(subimg);

[x, y] = size(ndvi);
for i=1:x
    for j=1:y
        if ndvi(i, j) < setting.NDVI_THRESHOLD
            subimg(i, j, :)  = 0;
        end
        
        if subimg(i,j,setting.NIR_INDEX) < setting.NIR_THRESHOLD
            subimg(i, j, :)  = 0;
        end
    end
end

%% Plot the actual image and the subimg

flightDetails = 'FLIGHT DETAILS';
[rgb0, envi_figure, envi_h] = toRGB(envi.z, flightDetails); %Normalize for it, memory faced in normalizin
[rgb,subimg_figure, subimg_h] = toRGB(subimg, flightDetails);

% Reflectance mouse picker

wavelength_titles = envi.info.wavelength';
reflectance_figure = figure;
set(envi_h,'ButtonDownFcn',{@ImageClickCallback, wavelength_titles, envi.z, envi_figure, reflectance_figure});
set(subimg_h,'ButtonDownFcn',{@ImageClickCallback, wavelength_titles, subimg, subimg_figure, reflectance_figure});

%% merge with LiDAR

p1 = [1,1; 2,2;3,3];
p2 = [0 ,0;1,1; 3,3; 4,4; 5,5];
pdist2(p1,p2)

[mesh_flight4_X, mesh_flight4_Y]= meshgrid(envi.x, envi.y);
mesh_flight_4 = cat(3, mesh_flight4_X, mesh_flight4_Y);
mesh_flight_4_reshaped = reshape(mesh_flight_4, 2, []);

%%
%%
%% read each ROI csv files, extract relevant reflectance from envi

[rgb0, envi_figure, envi_h] = toRGB(envi.z, flightDetails);
for i = 1:13
    plotROI(envi_figure, envi, i);
end

%% Mark an already known spot in image

markCoordinate(envi_figure, envi, 402424.06,  3283571.80 )

addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/io/csvIO');
[ specie, reflectance, roi, northing, easting, flight ] = get_field_pixels();
for i = 1: numel(northing)
    markCoordinate(envi_figure, envi, easting(i),  northing(i) )
end
%% Display hsi_img at differnet bands.

[n_row,n_col,n_band] = size(subimg);
for i=40:n_band
    figure(10);
    imagesc(subimg(:,:,i)); % creates heat map of that frequency
    % imshow(hsi_img(:,:,i)) % will only create grey image - not good
    title(sprintf('Band %f', envi.info.wavelength(i)));
    pause(0.05);
    %pause(1);
end

%% Generate 1-D csv file

hsi2scidb(normalized_subimg, 'normalized_subimg.csv');
hsi2scidb(hsi_img, 'hsi_img.csv');

%% lasread - AWESOME fast!!!

addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/lidar/');
binResolution = 2; % bin side length in meters

tic
lidar_file08 = '/cise/homes/msnia/neon/lidar/DL20100901_osbs_FL08_discrete_lidar_NEON-L1B/DL20100901_osbs_FL08_discrete_lidar_NEON-L1B.las';
[baseX08, baseY08, heightMap08] = getHeightMap(lidar_file08, binResolution);
lidar_file09 = '/cise/homes/msnia/neon/lidar/DL20100901_osbs_FL09_discrete_lidar_NEON-L1B/DL20100901_osbs_FL09_discrete_lidar_NEON-L1B.las';
[baseX09, baseY09, heightMap09] = getHeightMap(lidar_file09, binResolution);
toc
TODO load all field data and loop through all pixels for a tree and try to come up with an aggregate  tree height
targetX = 402536;
targetY = 3283512;

height08 = getHeight( heightMap08, baseX08, baseY08, binResolution, targetX, targetY );
height09 = getHeight( heightMap09, baseX09, baseY09, binResolution, targetX, targetY );
disp([height08 height09]);


%% SPICE: linear unmixing - not suitable for neon dataset

addpath('/home/scidb/zproject/neonDSR/code/matlab/uf/PCBootstrapSPICE');
addpath('/home/scidb/zproject/neonDSR/code/matlab/uf/PCBootstrapSPICE/qpc');
addpath('/home/scidb/zproject/neonDSR/code/matlab/uf/fast_spice');

spice_params = SPICEParameters();
spice_params.produceDisplay = 1;
spice_params.endmemberPruneThreshold = 1e-2;
spice_params.iterationCap=10;
spice_params.gamma = 1;
spice_params.M = 5; %Initial number of endmembers
spice_params.u = 0.0001; %Trade-off parameter between RSS and V term
% Try many values of u until you find something
% that works. Maybe try values logarithmically spaced from 10^-6 to 1.

[n_row,n_col,n_band] = size(normalized_subimg); %size(X.Data)

sub_data = reshape(normalized_subimg,n_row*n_col,n_band)';

[E,P] = SPICE(double(sub_data),spice_params);

figure(10); plot(E); xlabel('wavelength'); ylabel('reflectance');
% TODO: don't forget legend.
% x-axis should be wavelength, not wavelength index.

for i=1:spice_params.M
    h = figure;     p1 = P(:,i);     imagesc(reshape(p1,n_row,n_col));    colorbar;  xlabel('Latitude'); ylabel('Longtitude'); title (sprintf('Heat-map of Endmember #%d',i));
    % print(fig, '-djpeg', sprintf('%d'), i);
    saveas(h,sprintf('heatmap-%1d', i),'png');
    h = figure; plot(envi.info.wavelength, E(:, i)); xlabel('Wavelength(nm)'); ylabel('Reflectance'); title (sprintf('Reflectance-Wavelength intensity of Endmember #%d',i));
    saveas(h,sprintf('endmember-%1d', i),'png');
end

%% SPICEE: The correct version of Spice by Taylor

addpath('/home/scidb/zproject/neonDSR/code/matlab/uf/spicee');
addpath('/home/scidb/zproject/neonDSR/code/matlab/uf/PCBootstrapSPICE/qpc');
%addpath('/home/scidb/zproject/neonDSR/matlab/uf/fast_spice');

[n_row,n_col,n_band] = size(normalized_subimg); %size(X.Data)

sub_data = reshape(normalized_subimg,n_row*n_col,n_band)';
subdata = double(sub_data);

max_num = max(subdata(:));
min_num = min(subdata(:));
normalizedSubdata = double((subdata - min_num)) / double((max_num - min_num));

% Try many values of u until you find something that works. Maybe try values logarithmically spaced from 10^-6 to 1.
spice_params = SPICEParameters();
%spice_params.endmemberPruneThreshold = 1e-2;
%spice_params.u = 0.0001; %Trade-off parameter between RSS and V term
[E,P] = SPICE(normalizedSubdata, spice_params);

figure(10); plot(E); xlabel('wavelength'); ylabel('reflectance');

for i=1:size(P,2)   % only show non-pruned endmembers
    h = figure; subplot(2,1,1),     p1 = P(:,i);     imagesc(reshape(p1,n_row,n_col)); axis image;   colorbar;  xlabel('Latitude'); ylabel('Longtitude'); title (sprintf('Heat-map of Endmember #%d',i));
    % print(fig, '-djpeg', sprintf('%d'), i);
    saveas(h,sprintf('heatmap-%1d', i),'png');
    %  h = figure;
    subplot(2,1,2), plot(envi.info.wavelength, E(:, i));
    xlabel('Wavelength(nm)'); ylabel('Reflectance');
    title (sprintf('Reflectance-Wavelength intensity of Endmember #%d',i));
    set(gca,'YTick',[0:500:max(E(:, i))])
    set(gca,'XTick',[0:100:max(wavelength)])
    grid on;
    
    set(h, 'Position', [100 100 900 400])
    saveas(h,sprintf('endmember-%1d', i),'png');
end

close all;

%% PCOMMEND: non-linear unmixing, well suited for neon dataset

addpath('/home/scidb/zproject/neonDSR/matlab/uf/PCOMMEND');

%[n_row,n_col,n_band] = size(normalized_subimg);

%normalized_subimg_data = reshape(normalized_subimg,n_row*n_col,n_band)';

params = PCOMMEND_Parameters();
E = PCOMMEND(double(sub_data), params);

for b = 1:length(E)
    figure(b)
    T = E{b};
    plot(T(1, :)); ylim([0 1]);
    hold on
    plot(T(2, :)); ylim([0 1]);
    hold off
end

%% PCOMMEND: Taylor snippet

%campus1_setup; % replace this with the setup for your data

addpath('/home/scidb/zproject/neonDSR/matlab/uf/PCOMMEND');

envi = enviread('/home/scidb/neon/f100910t01p00r02rdn/f100910t01p00r02rdn_b_NEON-L1G/f100910t01p00r02rdn_b_sc01_ort_flaashreflectance_img');
hsi_img = envi.z;

subimg = hsi_img(1200:1400 , 400:600, :);

params = PCOMMEND_Parameters;
params.iterationCap = 100;
params.C = 4;
params.M = 3;

[n_row,n_col,n_band] = size(subimg);
n_pix = n_row*n_col;

hsi_data = double(reshape(subimg,n_row*n_col,n_band));

[E,P,U,obj] = PCOMMEND(hsi_data',params); %wants data to be n_pix x n_band

for i=1:params.C
    % show membership map for each partition
    figure(10+i);
    mem = U(i,:);
    imagesc(reshape(mem,[n_row,n_col]),[0 1]);
    colorbar;
    title(sprintf('PCOMMEND region %d membership',i));
    
    % plot endmembers for each partition
    figure(20+i);
    plot(E{i}');
    title(sprintf('PCOMMEND region %d endmembers',i));
    
    % plot proportion maps for each endmember
    figure(30+i);
    for j=1:params.M
        subplot(2,2,j);
        imagesc(reshape(P{i}(:,j),[n_row,n_col]),[0 1]);
        title(sprintf('proportion map %d,%d',i,j));
    end
end

%% load LiDAR data (LIght Detection And Ranging)   -- VERY SLOW
mode = 1; % | 2
disp(['Time: ' datestr(now, 'HH:MM:SS')])
if exist('/cise/', 'file')
    addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/uf/');
    [DataPoints, Coords] = readLAS('/cise/homes/msnia/neon/lidar/DL20100901_osbs_FL09_discrete_lidar_NEON-L1B/DL20100901_osbs_FL09_discrete_lidar_NEON-L1B.las', mode);
else
    [DataPoints, Coords] = readLAS('/home/scidb/neon/f100910t01p00r02rdn/lidar/lidar/DL20100901_osbs_FL10_discrete_lidar_NEON-L1B.las', mode);
end
disp(['Time: ' datestr(now, 'HH:MM:SS')])



% Unique items in data
numel(unique(Coords(:, 1))) % Unique X's
numel(unique(Coords(:, 2))) % Unique Y's
size(unique(Coords(:, [1,2]), 'rows')) % Unique X,Y combinations

hist(DataPoints(:,[2]))%---------------
title (sprintf('Histogram of Lidar Returns')); xlabel('Lidar Return #'); ylabel('# of Points');


hist(Coords(:,3), 200) % histogram of heights
title (sprintf('Histogram of Lidar Data')); xlabel('Height'); ylabel('# of Points in Histogram Bin');

temp = Coords(Coords < 100);
temp = temp(temp > -1);
hist(temp, 200)
title (sprintf('Histogram of Lidar Data - After Removing Outliers')); xlabel('Height'); ylabel('# of Points in Histogram Bin');
