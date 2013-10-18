

%enviread('/home/morteza/zproject/neon/envi/f100910t01p00r02rdn_b_NEON-L1B/f100910t01p00r02rdn_b_flaashreflectance_img');
%envi = enviread('/home/morteza/zproject/neon/fulldataset/f100910t01p00r02rdn/f100910t01p00r02rdn_b_NEON-L1G/f100910t01p00r02rdn_b_sc01_ort_flaashreflectance_img');

% Read ENVI file
envi = enviread('/home/scidb/neon/f100910t01p00r02rdn/f100910t01p00r02rdn_b_NEON-L1G/f100910t01p00r02rdn_b_sc01_ort_flaashreflectance_img');

% Generate RGB
hsi_img = envi.z;
rgb = iRGB(hsi_img);

% Generate RGB of subimg
% subimg = hsi_img(1330:1430 , 450:500, :);
subimg = hsi_img(1200:1400 , 400:600, :);
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
%spice_params.iterationCap=50;
spice_params.gamma = 1;
parameters.M = 20; %Initial number of endmembers
parameters.u = 0.0001; %Trade-off parameter between RSS and V term
% Try many values of u until you find something
% that works. Maybe try values logarithmically spaced from 10^-6 to 1.

[n_row,n_col,n_band] = size(subimg); %size(X.Data)

sub_data = reshape(subimg,n_row*n_col,n_band)';

[E,P] = SPICE(double(sub_data),spice_params);

figure(10); plot(E); xlabel('wavelength'); ylabel('reflectance');


for i=1:10
    figure(10+i);     p1 = P(:,i);     imagesc(reshape(p1,n_row,n_col));    colorbar;
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
