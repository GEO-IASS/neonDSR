function iRGB(hsi_img)

    red = hsi_img(:,:,37);
	green = hsi_img(:,:,20);
	blue = hsi_img(:,:,10);
rgb = cat(3, red, green, blue);

	max_num = max(rgb(:));
	min_num = min(rgb(:));
normalizedRGB = double((rgb - min_num)) / double((max_num - min_num));

figure
image(sqrt(normalizedRGB));
colorbar


end