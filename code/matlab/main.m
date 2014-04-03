rcd('/home/scidb/zproject/neonDSR/code/matlab/');
 
%% Load ENVI file

%enviread('/home/morteza/zproject/neon/envi/f100910t01p00r02rdn_b_NEON-L1B/f100910t01p00r02rdn_b_flaashreflectance_img');
%envi = enviread('/home/morteza/zproject/neon/fulldataset/f100910t01p00r02rdn/f100910t01p00r02rdn_b_NEON-L1G/f100910t01p00r02rdn_b_sc01_ort_flaashreflectance_img');

format long g; % avoid scientific notation

% Read ENVI file
envi = enviread('/home/scidb/neon/f100910t01p00r02rdn/f100910t01p00r02rdn_b_NEON-L1G/f100910t01p00r02rdn_b_sc01_ort_flaashreflectance_img');

% Work on sub-image to save memory
hsi_img = envi.z;

subimg = double(hsi_img(1200:1400 , 400:600, :));
%subimg = hsi_img;
%clear hsi_img;
%subimg = double(subimg + 0);
%subimg(subimg<0) = 0; % filter out negative noises
%subimg(subimg>10000) = 10000; % filter out large noises


%subimg_mean = mean(subimg(:));
%subimg_std = std(double(subimg(:)));
%subimg(subimg>(subimg_mean + 2 *subimg_std))=0; % filter outlier 95 percentile

% Normalize: rflectance should be [0, 1]
%max_num = max(subimg(:));
%min_num = min(subimg(:));
%subimg = double((subimg - min_num)) / double((max_num - min_num));

%subimg = subimg/2.0;

clearvars subimg subimg_mean subimg_std max_num min_num;

[rgb0, hsi_figure0, h0] = iRGB(hsi_img); %Normalize for it, memory faced in normalizin
[rgb, hsi_figure, h] = iRGB(subimg);

%figure, hist(normalized_subimg(:));

%% Reflectance mouse picker

wavelength_titles = envi.info.wavelength';
reflectance_figure = figure;
set(h,'ButtonDownFcn',{@ImageClickCallback, wavelength_titles, subimg, hsi_figure, reflectance_figure});

%% Mark an already known spot in image

markCoordinate(hsi_figure, envi, 402579.16,  3283733.50 )
%building in subimg
%markCoordinate(hsi_figure, envi, 402579.16, 3286162.00000000 )


%% Display hsi_img at differnet bands.

[n_row,n_col,n_band] = size(hsi_img);
for i=40:n_band
   figure(10);
   imagesc(hsi_img(:,:,i)); % creates heat map of that frequency
   % imshow(hsi_img(:,:,i)) % will only create grey image - not good
   title(sprintf('Band %f', envi.info.wavelength(i)));    
   pause(0.05);
   %pause(1);
end

%% Ensure Seamless stepsize
first_StepX = envi.x(2) - envi.x(1);
consistent_x_step = true;
for i=2:size(envi.x')
   if envi.x(i) - envi.x(i-1) == first_StepX
      %     disp('=')  
   else
     consistent_x_step = false

   end
end
if consistent_x_step == false
    disp('INCONSISTENT step size')
else
    disp('X step sizes, OK')
end

first_StepY = envi.y(2) - envi.y(1);
consistent_y_step = true;
for i=2:size(envi.y')
   diff = envi.y(i) - envi.y(i-1);
   if (diff == first_StepY)
     %disp('=')  
   else
     consistent_y_step = false
   end
end
if consistent_y_step == false
    disp('INCONSISTENT step size')
else
    disp('Y step sizes, OK')
end


%% Generate NDVI

nir = double(hsi_img(:,:,42));
red = double(hsi_img(:,:,37));
ndvi_numerator = nir - red;
max(ndvi_numerator(:))
min(ndvi_numerator(:))
ndvi_denominator = nir + red;
ndvi =  ndvi_numerator ./ ndvi_denominator;

   ndvi2560 = 2560 * ndvi;
   f = floor(ndvi2560);
   figure(8);
   imagesc(f );

   figure(9);
   imshow( ndvi);
   colorbar;

   figure(10);
   imagesc(ndvi_numerator);
   
   figure(11);
   imagesc(ndvi_denominator);
   
  % title(sprintf('Band %f', envi.info.wavelength(i)));    
  % pause(0.05);

%% Generate 1-D csv file
 
hsi2scidb(normalized_subimg, 'normalized_subimg.csv');
hsi2scidb(hsi_img, 'hsi_img.csv');

%% load LiDAR data (LIght Detection And Ranging)

addpath('/home/scidb/zproject/neonDSR/code/matlab/uf/');
mode = 1; % | 2
datestr(now, 'HH:MM:SS')
[DataPoints, Coords] = readLAS('/home/scidb/neon/f100910t01p00r02rdn/lidar/lidar/DL20100901_osbs_FL10_discrete_lidar_NEON-L1B.las', mode);
datestr(now, 'HH:MM:SS')

% Unique items in data
numel(unique(Coords(:, 1))) % Unique X's
numel(unique(Coords(:, 2))) % Unique Y's
size(unique(Coords(:, [1,2]), 'rows')) % Unique X,Y combinations

hist(DataPoints(:,[2]))+---------------
title (sprintf('Histogram of Lidar Returns')); xlabel('Lidar Return #'); ylabel('# of Points');


hist(Coords(:,3), 200) % histogram of heights
title (sprintf('Histogram of Lidar Data')); xlabel('Height'); ylabel('# of Points in Histogram Bin');

temp = Coords(Coords < 100);
temp = temp(temp > -1);
hist(temp, 200)
title (sprintf('Histogram of Lidar Data - After Removing Outliers')); xlabel('Height'); ylabel('# of Points in Histogram Bin');

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

