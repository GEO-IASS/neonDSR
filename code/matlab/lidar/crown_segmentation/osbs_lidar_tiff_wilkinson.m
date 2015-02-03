


filename = '/Users/morteza/Downloads/CHM_all.tif';
%filename = '/Users/morteza/Downloads/DSM_all.tif';
%filename = '/Users/morteza/Downloads/Filt_Hillshade_all.tif';
[X, cmap, R] = geotiffread(filename);

X(X<0)=0;

X1 = X(7000:9000, 4000:6000);
X1 = X(8400:8600, 4400:4900);
%X1 = X(8500:8600, 4400:4500);
%X1 = X(8550:8600, 4450:4500);

figure, imshow(X1), title('0')

L = watershed(X1);
figure, imshow(label2rgb(L)), title('6')

Lbw=L;
Lbw(Lbw>0)=2;

Lbw(Lbw==0)=1;
Lbw(Lbw==2)=0;

overlay1 = imoverlay(X1,Lbw,[.3 1 .3]);
figure, imshow(overlay1) , title('3')





      I = imread('cameraman.tif');
      bw = edge(I, 'canny');
      rgb = imoverlay(I, bw, [0 1 0]);
      imshow(rgb)

%figure
%geoshow(x,map,R)

%%

% Make a binary image containing two overlapping circular objects.

center1 = -10;
center2 = -center1;
dist = sqrt(2*(2*center1)^2);
radius = dist/2 * 1.4;
lims = [floor(center1-1.2*radius) ceil(center2+1.2*radius)];
[x,y] = meshgrid(lims(1):lims(2));
bw1 = sqrt((x-center1).^2 + (y-center1).^2) <= radius;
bw2 = sqrt((x-center2).^2 + (y-center2).^2) <= radius;
bw = bw1 | bw2;
figure, imshow(bw,'InitialMagnification','fit'), title('bw')

%Compute the distance transform of the complement of the binary image.

D = bwdist(~bw);
figure, imshow(D,[],'InitialMagnification','fit')
title('Distance transform of ~bw')

%Complement the distance transform, and force pixels that don't belong to the objects to be at -Inf.

D = -D;
D(~bw) = -Inf;

%Compute the watershed transform and display the resulting label matrix as an RGB images.

L = watershed(D);
rgb = label2rgb(L,'jet',[.5 .5 .5]);
figure, imshow(rgb,'InitialMagnification','fit')
title('Watershed transform of D')

%%

I_cropped = X;

I_eq = adapthisteq(I_cropped);
figure, imshow(I_eq), title('1')

% So what happens if we just apply a threshold now?

bw = im2bw(I_eq, graythresh(I_eq));
figure, imshow(bw), title('2')

% Let's clean that up and then overlay the perimeter on the original image.

bw2 = imfill(bw,'holes');
bw3 = imopen(bw2, ones(5,5));
bw4 = bwareaopen(bw3, 40);
bw4_perim = bwperim(bw4);
overlay1 = imoverlay(I_eq, bw4_perim, [.3 1 .3]);
figure, imshow(overlay1) , title('3')

%%

%  The extended maxima operator can be used to identify groups of pixels that
% are significantly higher than their immediate surrounding.

mask_em = imextendedmax(I_eq, 30);
figure, imshow(mask_em), title('4')

% Let's clean that up and then overlay it.

mask_em = imclose(mask_em, ones(5,5));
mask_em = imfill(mask_em, 'holes');
mask_em = bwareaopen(mask_em, 40);
overlay2 = imoverlay(I_eq, bw4_perim | mask_em, [.3 1 .3]);
figure, imshow(overlay2), title('5')

% Next step: complement the image so that the peaks become valleys. We do 
% this because we are about to apply the watershed transform, which identifies 
% low points, not high points.

I_eq_c = imcomplement(I_eq);

% Next: modify the image so that the background pixels and the extended maxima 
% pixels are forced to be the only local minima in the image.

I_mod = imimposemin(I_eq_c, ~bw4 | mask_em);

% Now compute the watershed transform.

L = watershed(I_mod);
figure, imshow(label2rgb(L)), title('6')
