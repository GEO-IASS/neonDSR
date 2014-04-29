function TEX_IMG = WindowFeatures(feature_func, Intensity_IMG, WIN_SIZE)
	%Usage
	%
	%TEX_IMG = WindowFeatures(@entropy, double(LIDAR./max(max(LIDAR))), 5);
	%
	%Input
	%
	%feature_func - a function with which to run texture features : ex. entropy
	%Intensity_IMG - a HxW image of doubles (0.0-1.0)
	%WIN_SIZE      - size of the window to use (odd numbers only) : ex. 3,5,7
	%
	%Output
	%TEX_IMG - The textured image.
	I = Intensity_IMG;
	W = size(I,2);
	H = size(I,1);
	SZ = WIN_SIZE;
	TEX_IMG = zeros([H W 4]);
	for i=1:H
	for j=1:W
		YRange = max(i-floor(WIN_SIZE/2),1):min(i+floor(WIN_SIZE/2),H);
		XRange = max(j-floor(WIN_SIZE/2),1):min(j+floor(WIN_SIZE/2),W);
		WINDOW_ij = Intensity_IMG( YRange, XRange);
		TEX_IMG(i,j,:) = feature_func(WINDOW_ij);
	end
	end
	figure();
%	subplot(2,2,1);
	imagesc(TEX_IMG(:,:,1));
%	hold on;
%	title(strcat('Contrast '));
%	subplot(2,2,2);
%	imagesc(TEX_IMG(:,:,2));
%	title(strcat('Correlation '));
%	subplot(2,2,3);
%	imagesc(TEX_IMG(:,:,3));
%	title(strcat('Energy '));
%	subplot(2,2,4);
%	imagesc(TEX_IMG(:,:,4));
%	title(strcat('Homogeneity'));
end
