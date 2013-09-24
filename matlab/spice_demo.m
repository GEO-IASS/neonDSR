%-- 09/20/2013 01:29:02 PM --%
addpath('/media/sde/neon/downloadedData/hsi_stuff/hsitoolkit/');
addpath('/media/sde/neon/downloadedData/hsi_stuff/hsitoolkit/PCBootstrapSPICE/');
envi = enviread('/media/sde/neon/envi/f100910t01p00r03rdn_b_NEON-L1B/f100910t01p00r03rdn_b_flaashreflectance_img')
envi = enviread('/media/sde/neon/downloadedData/envi/f100910t01p00r03rdn_b_NEON-L1B/f100910t01p00r03rdn_b_flaashreflectance_img');
envi = read_envihdr('/media/sde/neon/downloadedData/envi/f100910t01p00r03rdn_b_NEON-L1B/f100910t01p00r03rdn_b_flaashreflectance_img.hdr');
envi = enviread('/media/sde/neon/downloadedData/envi/f100910t01p00r03rdn_b_NEON-L1B/f100910t01p00r03rdn_b_flaashreflectance_img');
params = SPICEParameters();
addpath('/media/sde/neon/downloadedData/hsi_stuff/hsitoolkit/fas_spice/');
addpath('/media/sde/neon/downloadedData/hsi_stuff/hsitoolkit/fast_spice/');
params = SPICEParameters();
params.produceDisplay = 1;
params.endmemberPruneThreshold = 1e-3;
[n_row,n_col,n_band] = size(hsi_img);
[n_row,n_col,n_band] = size(envi.z);
hsi_data = reshape(hsi_img,n_row*n_col,n_band)';
hsi_img = envi.z;
hsi_data = reshape(hsi_img,n_row*n_col,n_band)';
[E,P] = SPICE(hsi_data,params);
[E,P] = SPICE(double(hsi_data),params);
addpath('/media/sde/neon/downloadedData/hsi_stuff/hsitoolkit/PCBootstrapSPICE/qpc');
[E,P] = SPICE(double(hsi_data),params);
params.iterationCap = 25;
[E,P] = SPICE(double(hsi_data),params);
params.iterationCap = 2;
[E,P] = SPICE(double(hsi_data),params);
figure(10); plot(E); xlabel('wavelength'); ylabel('reflectance');
for i=1:5
figure(10+i);     p1 = P(:,i);     imagesc(reshape(p1,n_row,n_col));    colorbar;
end
for i=1:10
figure(10+i);     p1 = P(:,i);     imagesc(reshape(p1,n_row,n_col));    colorbar;
end
for i=1:10
figure(10+i);     p1 = P(:,i);     imagesc(reshape(p1,n_row,n_col));    colorbar;
end
imagesc(hsi_image(:,:,10))
imagesc(hsi_img(:,:,10))
rgb = (n_row, n_col, 3) = 0;
rgb = zeros(n_row, n_col, 3);
red = hsi_img(:,:,10);
imshow(red, []);
green = hsi_img(:,:,20);
red = hsi_img(:,:,37);
blue = hsi_img(:,:,10);
imshow(blue, []);
rgb = [red;green;blue];
imshow(rgb);
[rows,~]=size(red); colMax=max(abs(red),[],1); normalizedRed=red./repmat(colMax,rows,1);
normalizedRed = mat2gray(red);
imshow(normalizedRed);
normalizedBlue = mat2gray(blue);
normalizedGreen = mat2gray(green);
rgb = cat(3,normalizedRed, normalizedGreen, normalizedBlue);
imshow(rgb);
red = hsi_img(:,:,37);
green = hsi_img(:,:,20);
blue = hsi_img(:,:,10);
normalizedRed = mat2gray(red);
normalizedGreen = mat2gray(green);
normalizedBlue = mat2gray(blue);
rgb = cat(3,normalizedRed, normalizedGreen, normalizedBlue);
imshow(rgb);
rgb = cat(3,normalizedRed, normalizedGreen, normalizedBlue);
imshow(rgb);
rgb = cat(3,normalizedBlue, normalizedGreen, normalizedRed);
imshow(rgb);
rgb = cat(3,normalizedBlue, normalizedRed, normalizedGreen);
imshow(rgb);
red(red < 0) = 0
red(red < 0) = 0;
red = hsi_img(:,:,37);
positiveRed = red(red > 0);
positiveRed = red;
positiveRed(positiveRed < 0) = 0;
hsi_img_max_val = max(hsi_img(:));
positiveRed = positiveRed / hsi_img_max_val;
positiveGreen = green;
positiveGreen(positiveGreen < 0) = 0;
positiveGreen = positiveGreen / hsi_img_max_val;
positiveBlue = blue;
positiveBlue(positiveBlue < 0) = 0;
positiveBlue = positiveBlue / hsi_img_max_val;
rgb = cat(3,positiveRed, positiveGreen, positiveBlue);
imshow(rgb);
imshow(unit16(rgb));
imshow(im2double(rgb));
rgb(1:5, 1:5, 1:5)
rgb(1:5, 1:5, 1:3)
positiveRed = red;
positiveRed(positiveRed < 0) = 0;
positiveGreen = green;
positiveGreen(positiveGreen < 0) = 0;
positiveBlue = blue;
positiveBlue(positiveBlue < 0) = 0;
rgb = cat(3,positiveRed, positiveGreen, positiveBlue);
rgb(1:5, 1:5, 1:3)
temp = rgb /hsi_img_max_val;
temp(1:5, 1:5, 1:3)
temp = rgb /double(hsi_img_max_val );
temp(1:5, 1:5, 1:3)
temp = rgb /(hsi_img_max_val * 249 );
temp(1:5, 1:5, 1:3)
temp = rgb /(hsi_img_max_val ) * 249;
temp(1:5, 1:5, 1:3)
imshow(temp);
imshow(im2double(temp));
temp2 = im2double(temp);
temp2(1:5, 1:5, 1:3)
temp = rgb /(hsi_img_max_val + 0.1);
temp(1:5, 1:5, 1:3)
temp = rgb /(hsi_img_max_val + 0.1) - 0.01;
temp = (rgb - 0.1 )/(hsi_img_max_val + 0.1) - 0.01;
rgb - 0.1
double(temp)
addpath('/media/sde/neon/downloadedData/hsi_stuff/temp/HSImageExplorerCodeFinal');
hyperspectralImageExplorer
temp(1:5, 1:5, 1:3)
rgb(1:5, 1:5, 1:3)
im2double(rgb(1:5, 1:5, 1:3))
imshow(im2double(rgb(1:5, 1:5, 1:3)))
imshow(im2double(rgb(1:5, 1:5, 1:3)));
imshow(im2double(rgb));
close all;
imshow(im2double(rgb));
imshow(double(rgb));
double(rgb(1:5, 1:5, 1:3))
rgb(1:5, 1:5, 1:3)
rgbDoubled = double(rgb);
rgbDoubled = double(rgb)/hsi_img_max_val;
rgbDoubled = double(rgb)./hsi_img_max_val;
rgbDoubled = double(rgb) / double(hsi_img_max_val);
imshow(rgbDoubled);
imshow(im2double(rgb));
imshow(F(rgbDoubed);
imshow(F(rgbDoubed));
imshow(F(rgbDoubled));
imshow(F(rgb));

