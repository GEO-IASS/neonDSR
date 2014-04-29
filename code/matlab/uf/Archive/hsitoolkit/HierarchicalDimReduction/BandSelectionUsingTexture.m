function [BandReducedImage] = BandSelectionUsingTexture(InputImage)

%Set Window Size
windowSize = 9;


%Compute Entropy in Sliding Local Window for Each Image
for i = 1:size(InputImage,3)
    EntropyImage(:,:,i) = entropyfilt(InputImage(:,:,i)/max(max(InputImage(:,:,i))),ones(windowSize));
end
EntropyImage = reshapeImage(EntropyImage);

%Compute Sum of Entropy Images
SumOfEntropy = sum(EntropyImage,2);

%Compute Threshold
Threshold = graythresh(SumOfEntropy/max(SumOfEntropy))*max(SumOfEntropy);

%Remove Bands Below Threshold
BandsToKeep = find(SumOfEntropy >= Threshold);
BandReducedImage = InputImage(:,:,BandsToKeep);

