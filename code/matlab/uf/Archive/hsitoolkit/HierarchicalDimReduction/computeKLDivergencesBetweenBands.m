function [KLDivergences, KLDivergencesList, hists] = computeKLDivergencesBetweenBands(InputData);

NumCenters = 255;
if(length(size(InputData)) > 2)
    InputData = reshapeImage(InputData);
end
DataList = InputData/max(max(InputData));

%Compute Histograms
Centers = [1/NumCenters:1/NumCenters:1];
for i = 1:size(DataList,1)
	hists(i,:) = hist(DataList(i,:), Centers);
end

hists = hists+eps;

%Compute KL-divergences
for i = 1:size(DataList,1)
    for j = 1:size(DataList,1)
        KLDivergences(i,j) = sum(hists(i,:).*log(hists(i,:)./(hists(j,:)))) + sum(hists(j,:).*log(hists(j,:)./(hists(i,:))));
    end
end

%Sort in List order for linkage algorithm
temp = KLDivergences - diag(diag(KLDivergences));
KLDivergencesList = squareform(temp);

end

function pixelList = reshapeImage(imageData)

pixelList = reshape(shiftdim(imageData(:,:,:),2),size(imageData,3),size(imageData,1)*size(imageData,2));

end