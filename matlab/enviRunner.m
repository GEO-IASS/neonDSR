




addpath('/home/morteza/Dropbox/Neon/hsi_stuff/');
addpath('/home/morteza/Dropbox/Neon/hsi_stuff/hsitoolkit');
%envi = enviread('/home/morteza/zproject/neon/envi/f100910t01p00r02rdn_b_NEON-L1B/f100910t01p00r02rdn_b_flaashreflectance_img');
envi = enviread('/home/morteza/zproject/neon/fulldataset/f100910t01p00r02rdn/f100910t01p00r02rdn_b_NEON-L1G/f100910t01p00r02rdn_b_sc01_ort_flaashreflectance_img');
hsi_img = envi.z;
iRGB(hsi_img);

% subimg = hsi_img(1330:1430 , 450:500, :);
subimg = hsi_img(1200:1400 , 400:600, :);
%iRGB(subimg);

% subimg = hsi_img(1330:1331 , 450:451, :);
 %subimg = hsi_img(1330:1380, 450:500, :);   % 5 mins for 50*50
 
 
[n_row,n_col,n_band] = size(subimg); 
%hsi_data = reshape(subimg,n_row*n_col,n_band)';
subdata = reshape(subimg, n_row * n_col * n_band, 1);
csvwrite('/home/morteza/zproject/neon/envi/csvlist.csv',subdata);
