

%enviread('/home/morteza/zproject/neon/envi/f100910t01p00r02rdn_b_NEON-L1B/f100910t01p00r02rdn_b_flaashreflectance_img');
%envi = enviread('/home/morteza/zproject/neon/fulldataset/f100910t01p00r02rdn/f100910t01p00r02rdn_b_NEON-L1G/f100910t01p00r02rdn_b_sc01_ort_flaashreflectance_img');

% Read ENVI file
envi = enviread('/home/scidb/neon/f100910t01p00r02rdn/f100910t01p00r02rdn_b_NEON-L1G/f100910t01p00r02rdn_b_sc01_ort_flaashreflectance_img');

% Extract hsi images
hsi_img = envi.z;
subimg = hsi_img(1200:1400 , 400:600, :);

% Generate RGB of subimg
iRGB(hsi_img);
iRGB(subimg);

%%
% Display hsi_img at differnet bands.

[n_row,n_col,n_band] = size(hsi_img);
for i=40:n_band
   figure(10);
   imagesc(hsi_img(:,:,i)); % creates heat map of that frequency
   % imshow(hsi_img(:,:,i)) % will only create grey image - not good
   title(sprintf('Band %f', envi.info.wavelength(i)));    
   pause(0.05);
   %pause(1);
end

%%
% NDVI

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

%%
% Generate 1-D csv file
hsi2scidb(subimg, 'subimg.csv');
hsi2scidb(hsi_img, 'hsi_img.csv');

%%
% SPICE: linear (not suitable for neon??)

addpath('/home/scidb/zproject/neonDSR/matlab/uf/PCBootstrapSPICE');
addpath('/home/scidb/zproject/neonDSR/matlab/uf/PCBootstrapSPICE/qpc');
addpath('/home/scidb/zproject/neonDSR/matlab/uf/fast_spice');

spice_params = SPICEParameters();
spice_params.produceDisplay = 1;
spice_params.endmemberPruneThreshold = 1e-2;
spice_params.iterationCap=100;
spice_params.gamma = 1;
spice_params.M = 5; %Initial number of endmembers
spice_params.u = 0.0001; %Trade-off parameter between RSS and V term
% Try many values of u until you find something
% that works. Maybe try values logarithmically spaced from 10^-6 to 1.

[n_row,n_col,n_band] = size(subimg); %size(X.Data)

sub_data = reshape(subimg,n_row*n_col,n_band)';

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



%%
% PCOMMEND: linear should be more applicable. 

addpath('/home/scidb/zproject/neonDSR/matlab/uf/PCOMMEND');

%[n_row,n_col,n_band] = size(subimg); 

%subimg_data = reshape(subimg,n_row*n_col,n_band)';

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


%%
% SPICEE: linear (not suitable for neon??)

addpath('/home/scidb/zproject/neonDSR/code/matlab/uf/spicee');
addpath('/home/scidb/zproject/neonDSR/code/matlab/uf/PCBootstrapSPICE/qpc');
%addpath('/home/scidb/zproject/neonDSR/matlab/uf/fast_spice');



[n_row,n_col,n_band] = size(subimg); %size(X.Data)

sub_data = reshape(subimg,n_row*n_col,n_band)';

% Try many values of u until you find something that works. Maybe try values logarithmically spaced from 10^-6 to 1.
spice_params = SPICEParameters();
%spice_params.endmemberPruneThreshold = 1e-2;
%spice_params.u = 0.0001; %Trade-off parameter between RSS and V term 
[E,P] = SPICE(double(sub_data),spice_params);

figure(10); plot(E); xlabel('wavelength'); ylabel('reflectance');  

for i=1:size(P,2)   % only show non-pruned endmembers
    h = figure; subplot(2,1,1),     p1 = P(:,i);     imagesc(reshape(p1,n_row,n_col)); axis image;   colorbar;  xlabel('Latitude'); ylabel('Longtitude'); title (sprintf('Heat-map of Endmember #%d',i));
    % print(fig, '-djpeg', sprintf('%d'), i);
  %  saveas(h,sprintf('heatmap-%1d', i),'png');
  %  h = figure; 
    subplot(2,1,2), plot(envi.info.wavelength, E(:, i)); xlabel('Wavelength(nm)'); ylabel('Reflectance'); title (sprintf('Reflectance-Wavelength intensity of Endmember #%d',i));
   % saveas(h,sprintf('endmember-%1d', i),'png');
end

close all;