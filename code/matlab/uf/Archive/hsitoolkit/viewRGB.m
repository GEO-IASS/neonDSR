function [h] = viewRGB(I)
%this function is made as a convenience for viewing HSI images
%it is assumed that the object I conforms to the envireader structure
RedWavelength = 650;
GreenWavelength = 540;
BlueWavelength = 475;

RGBimage = getHSIBands(I, [RedWavelength, GreenWavelength, BlueWavelength]);
RGBimage = RGBimage + .15;
RGBimage(RGBimage > 1) = 1;
RGBimage(RGBimage < 0) = 0;
h = figure;
RGBimage(:,:,1) = imadjust(imadjust(RGBimage(:,:,1)));
RGBimage(:,:,2) = imadjust(imadjust(RGBimage(:,:,2)));
RGBimage(:,:,3) = imadjust(imadjust(RGBimage(:,:,3)));
% imagesc(RGBimage);

imagesc(I.x, I.y, RGBimage);
set(gca,'YDir','normal')
end