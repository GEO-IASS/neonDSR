




%addpath('/home/morteza/Dropbox/Neon/hsi_stuff/');
%addpath('/home/morteza/Dropbox/Neon/hsi_stuff/hsitoolkit');
%envi =
%enviread('/home/morteza/zproject/neon/envi/f100910t01p00r02rdn_b_NEON-L1B/f100910t01p00r02rdn_b_flaashreflectance_img');
%envi = enviread('/home/morteza/zproject/neon/fulldataset/f100910t01p00r02rdn/f100910t01p00r02rdn_b_NEON-L1G/f100910t01p00r02rdn_b_sc01_ort_flaashreflectance_img');

envi = enviread('/home/scidb/neon/f100910t01p00r02rdn/f100910t01p00r02rdn_b_NEON-L1G/f100910t01p00r02rdn_b_sc01_ort_flaashreflectance_img');

hsi_img = envi.z;
iRGB(hsi_img);

hsi2scidb(hsi_img, 'hsi_img.csv');


% subimg = hsi_img(1330:1430 , 450:500, :);
subimg = hsi_img(1200:1400 , 400:600, :);
iRGB(subimg);

hsi2scidb(subimg, 'subimg.csv');


% subimg = hsi_img(1330:1331 , 450:451, :);
 %subimg = hsi_img(1330:1380, 450:500, :);   % 5 mins for 50*50
 
 
%[n_row,n_col,n_band] = size(subimg); 
%hsi_data = reshape(subimg,n_row*n_col,n_band)';
%subdata = reshape(subimg, n_row * n_col * n_band, 1);
%csvwrite('/home/morteza/zproject/neon/envi/csvlist.csv',subdata);

%-------------------------------------------SPICE: linear (not suitable for
%neon??)

addpath('/home/scidb/zproject/neonDSR/matlab/uf/PCBootstrapSPICE');
addpath('/home/scidb/zproject/neonDSR/matlab/uf/PCBootstrapSPICE/qpc');
addpath('/home/scidb/zproject/neonDSR/matlab/uf/fast_spice');

params = SPICEParameters();
params.produceDisplay = 1;
params.endmemberPruneThreshold = 1e-3;
params.iterationCap=50;

[n_row,n_col,n_band] = size(subimg); %size(X.Data)

sub_data = reshape(subimg,n_row*n_col,n_band)';

[E,P] = SPICE(double(sub_data),params);

figure(10); plot(E); xlabel('wavelength'); ylabel('reflectance');


for i=1:10
    figure(10+i);     p1 = P(:,i);     imagesc(reshape(p1,n_row,n_col));    colorbar;
end


%---------------------------PCOMMEND: linear should be more applicable. 

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



