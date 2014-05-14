%% Main runner of all sections
% generic normalization - not suitable for hyperspectral data 
%envi.z = double((envi.z - min_num)) / double((max_num - min_num)); % scale envi.z



format long g; % avoid scientific notation
global setting
setting = struct('RED_INDEX', 34, 'NIR_INDEX', 41, 'GREEN_INDEX', 20, ...
                 'BLUE_INDEX', 10, 'NDVI_THRESHOLD', 0.4, 'NIR_THRESHOLD', 0.33);

%% Read ENVI file and Normalize ata reflectance range = [-32724, +32762] 

flightDetails = 'Morning f100904t01p00r04rdn_b: ATCOR4r';
if exist('/cise/', 'file')
  cd('/cise/homes/msnia/zproject/neonDSR/code/matlab');
  addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/');
  envi = enviread('/cise/homes/msnia/neon/morning/f100904t01p00r04rdn_b/f100904t01p00r04rdn_b_sc01_ort_img_atm.bsq');
else
  cd('/home/scidb/zproject/neonDSR/code/matlab/');
  envi = enviread('/home/users-share/allFlights/f100910t01p00r03rdn_b_NEON-L1G/f100910t01p00r03rdn_b_sc01_ort_flaashreflectance_img');
end

Check_XY_Have_Uniform_Step_Sizes(envi);

envi.z(envi.z<0) = 0; % filter out negative noises
envi.z(envi.z >=10000) = NaN; % filter out large noises
envi.z = double(double(envi.z) / 10000.1);
envi.z = sqrt(double(envi.z));

subimg = envi.z;
subimg = remove_noisy_bands(subimg);


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

[rgb0, envi_figure, envi_h] = toRGB(envi.z, flightDetails); %Normalize for it, memory faced in normalizin
[rgb,subimg_figure, subimg_h] = toRGB(subimg, flightDetails);

%% Reflectance mouse picker

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

%% SVM performance plots

% Evaluate Gaussian filter size on accuracy
rng(982451653); % large prime as seed for random generation

count = 21;
svm_results_gaussian = zeros(count, 1);
smoothing_windows = zeros(count, 1);

for i=1:count
   i
   smoothing_window_size =  rem(i,20);  % 25 runs per gaussian window
   smoothing_windows(i) = smoothing_window_size;
   svm_results_gaussian(i) = specie_svm_binary_k_fold(0, smoothing_window_size, 1);
end
figure;
boxplot(svm_results_gaussian, smoothing_windows);
    xlabel('Gaussian window size'); ylabel('Accuracy (%)'); 

%---------------------------------------------------------------------
% Evaluate polynomial degree of svm kernel for accuracy
rng(982451653); % large prime as seed for random generation

rbf_sigma_values = [0.000001 0.00001 0.0001 0.001 0.01 0.1 1 1.6 1.9 2 2.5  2.9 3 3.2 3.3 3.33 3.35 3.4 3.5 3.9 10 100 1000];
count = 10;
svm_results_poly = zeros(count, 1);
polynomial_orders = zeros(count, 1);

for i=1:count
   i
   polynomial_order = i;% rem(i,20);  % 25 runs per gaussian window
   polynomial_orders(i) = polynomial_order;
   svm_results_poly(i) = specie_svm_binary_k_fold(0, 4, polynomial_order);
end
figure;
plot(polynomial_orders(1:30), svm_results_poly(1:30));
    xlabel('SVM Kernel - polynomial degree'); ylabel('Accuracy (%)'); 

%---------------------------------------------------------------------
% Evaluate RBF sigma of svm kernel for accuracy
rng(982451653); % large prime as seed for random generation

rbf_sigma_values = [ 0.001 0.01 0.1 1 1.6 1.9 2 2.5  2.9 3 3.1 3.15 3.2 3.25 3 3.2 3.3 3.33 3.35 3.4 3.5 3.9 4.2 4.7 5 5.5 6 6.15 6.25 6.33 6.5 6.6 6.75 6.9 7 8 9 10];
count = numel(rbf_sigma_values);
svm_results_rbf = zeros(count, 1);

for i=1:count
   i
   svm_results_rbf(i) = specie_svm_binary_k_fold(0, 4, rbf_sigma_values(i));
end
figure;
semilogx(rbf_sigma_values, svm_results_rbf);
grid on
xlabel('SVM Kernel - RBF \sigma'); ylabel('Accuracy (%)');

    
%%
%%
%% read each ROI csv files, extract relevant reflectance from envi

[rgb0, envi_figure, envi_h] = toRGB(envi.z, flightDetails); 
for i = 1:13
  plotROI(envi_figure, envi, i);
end

%% Mark an already known spot in image

markCoordinate(envi_figure, envi, 402424.06,  3283571.80 )

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

disp(['Time: ' datestr(now, 'HH:MM:SS')])
addpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/lidar/');
lidar_file = '/cise/homes/msnia/neon/lidar/DL20100901_osbs_FL09_discrete_lidar_NEON-L1B/DL20100901_osbs_FL09_discrete_lidar_NEON-L1B.las';
params = 'xyz'; % 'A'
[s, h, v] = lasread(lidar_file, params);
zmean= mean(s.Z);
zstd = std(s.Z);
lidar = s.Z(s.Z <zmean + 3 * zstd );
hist(lidar, 200);
lasview(lastrim(s,50000),'z'); %sam
disp(['Time: ' datestr(now, 'HH:MM:SS')])

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
