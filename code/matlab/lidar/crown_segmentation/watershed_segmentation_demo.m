% http://blogs.mathworks.com/steve/2006/06/02/cell-segmentation/


init();
global setting;

addpath(strcat(setting.PREFIX, '/neonDSR/code/matlab/lidar/'));
addpath(strcat(setting.PREFIX, '/neonDSR/code/matlab/lidar/crown_segmentation'));
addpath(strcat(setting.PREFIX, '/neonDSR/code/matlab/lidar/crown_segmentation/imoverlay'));



I = imread('http://blogs.mathworks.com/images/steve/60/nuclei.png');
I_cropped = I(400:900, 465:965);
imshow(I_cropped)


% Strictly speaking, contrast adjustment isn't usually necessary for segmentation, 
% but it can help the algorithm developer see and understand the image data better.
% This is a fairly low-contrast image, so I thought it might help. You can adjust 
% the display contrast interactively with imtool, or you can use an automatic method 
% such as adapthisteq. adapthisteq implements a technique called contrast-limited 
% adaptive histogram equalization, or CLAHE. (I always thought "CLAHE" sounded like
% it must be some Klingon delicacy.)

I_eq = adapthisteq(I_cropped);
imshow(I_eq)

% So what happens if we just apply a threshold now?

bw = im2bw(I_eq, graythresh(I_eq));
imshow(bw)

% Let's clean that up and then overlay the perimeter on the original image.

bw2 = imfill(bw,'holes');
bw3 = imopen(bw2, ones(5,5));
bw4 = bwareaopen(bw3, 40);
bw4_perim = bwperim(bw4);
overlay1 = imoverlay(I_eq, bw4_perim, [.3 1 .3]);
imshow(overlay1)

%  The extended maxima operator can be used to identify groups of pixels that
% are significantly higher than their immediate surrounding.

mask_em = imextendedmax(I_eq, 30);
imshow(mask_em)

% Let's clean that up and then overlay it.

mask_em = imclose(mask_em, ones(5,5));
mask_em = imfill(mask_em, 'holes');
mask_em = bwareaopen(mask_em, 40);
overlay2 = imoverlay(I_eq, bw4_perim | mask_em, [.3 1 .3]);
imshow(overlay2)

% Next step: complement the image so that the peaks become valleys. We do 
% this because we are about to apply the watershed transform, which identifies 
% low points, not high points.

I_eq_c = imcomplement(I_eq);

% Next: modify the image so that the background pixels and the extended maxima 
% pixels are forced to be the only local minima in the image.

I_mod = imimposemin(I_eq_c, ~bw4 | mask_em);

% Now compute the watershed transform.

L = watershed(I_mod);
imshow(label2rgb(L))

