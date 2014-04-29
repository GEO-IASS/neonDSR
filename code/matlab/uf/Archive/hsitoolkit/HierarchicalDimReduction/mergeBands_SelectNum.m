function [band_clusters, mergedData] = mergeBands_SelectNum(InputData);

% Merge bands using Hierarchical Dimensionality Reduction
%   
% Syntax: [band_clusters, mergedData] = mergeBands(InputData);
%
% Inputs:
%   InputData - double Mat - NxM matrix of M data points of
%       dimensionality N (i.e.  M pixels with N spectral bands, each pixel is
%       a column vector)
%
% Outputs:
%   band_clusters - double Mat - Nx1 matrix indicating the cluster each
%       band was assigned to
%   mergedData - double Mat - numBandsxM matrix of reduced dimensionality
%       data
% Other m-files required: Statistics Toolbox, 
%
% Author: Alina Zare
% University of Florida, Computer Information Science and Engineering
%   Department
% Email Address: azare@ufl.edu
% Created: September 12, 2008
% Latest Revision: November 20, 2009

%%
%Set Parameters Here

type = 'complete'; %Type of Hierarchy
showH = 0; %Set to 1 to show clustering, 0 otherwise
NumCenters = 255; %Number of centers used in computing KL-divergence


%%
if(length(size(InputData)) > 2)
    InputData = reshapeImage(InputData);
end

[KLDivergences, KLDivergencesList, hists] = computeKLDivergencesBetweenBands(InputData, NumCenters);

Hierarchy = linkage(KLDivergencesList, type);
for i = 1:size(Hierarchy, 1)
    V(i) = var(Hierarchy(1:i,3));
end
difference = acosd(1./sqrt(1+(diff(V/max(V))).^2));
difference = (difference - .45).*(difference - .45);
[val location] = min(difference);
maxNumClusters = size(InputData, 1) - location;

if(showH)
    D = dendrogram(Hierarchy, 0);
end
band_clusters = cluster(Hierarchy,'maxclust',maxNumClusters) ;

for i = 1:maxNumClusters
    locations = find(band_clusters == i);
    Ksub = KLDivergences(band_clusters == i, band_clusters == i);
    [v loc] = min(sum(Ksub));
    mergedData(i,:) = InputData(locations(loc),:);
    %mergedData(i,:) = mean(InputData(find(band_clusters == i),:),1);
    %mergedData(i,:) = min(InputData(find(band_clusters == i),:),[],1);
end
end

%%
function [KLDivergences, KLDivergencesList, hists] = computeKLDivergencesBetweenBands(InputData, NumCenters);


DataList = InputData/max(max(InputData));

%Compute Histograms
Centers = [1/NumCenters:1/NumCenters:1];
hists = hist(DataList', Centers);
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


%%
function pixelList = reshapeImage(imageData)

pixelList = reshape(shiftdim(imageData(:,:,:),2),size(imageData,3),size(imageData,1)*size(imageData,2));

end