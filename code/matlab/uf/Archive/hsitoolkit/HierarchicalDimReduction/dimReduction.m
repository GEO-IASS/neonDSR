function [dimReductionStruct] = dimReduction(HylidImage, Parameters)

% This product is Copyright (c) 2011 University of Missouri.
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions
% are met:
%
%   1. Redistributions of source code must retain the above copyright
%      notice, this list of conditions and the following disclaimer.
%   2. Redistributions in binary form must reproduce the above copyright
%      notice, this list of conditions and the following disclaimer in the
%      documentation and/or other materials provided with the distribution.
%   3. Neither the name of the University nor the names of its contributors
%      may be used to endorse or promote products derived from this software
%      without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE UNIVERSITY OF MISSOURI AND
% CONTRIBUTORS ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED.  IN NO EVENT SHALL THE UNIVERSITY OR CONTRIBUTORS
% BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES,
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
% OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


%%
%Save Previous Results if Flag set

%Initialize
try
    %InputData = HylidImage.MeasuredData;
    InputData = HylidImage.Data;

catch
    error('Input Image must be in the Hylid Image Format');
end
numRows = size(InputData,1);
numCols = size(InputData,2);
numDims = size(InputData,3);


%Perform Hierarchical DImensionality Reduction

type = Parameters.type; %Type of Hierarchy
showH = Parameters.showH; %Set to 1 to show clustering, 0 otherwise
maxNumClusters = Parameters.numBands; 
NumCenters = Parameters.NumCenters; %Number of centers used in computing KL-divergence


%%
if(length(size(InputData)) > 2)
    InputData = reshapeImage(InputData);
end

[KLDivergences, KLDivergencesList, hists] = computeKLDivergencesBetweenBands(InputData, NumCenters);

Hierarchy = linkage(KLDivergencesList, type);
if(showH)
    D = dendrogram(Hierarchy, 0);
end
band_clusters = cluster(Hierarchy,'maxclust',maxNumClusters) ;

for i = 1:maxNumClusters
    mergedData(i,:) = mean(InputData(band_clusters == i,:),1);
end

for i = 1:maxNumClusters
    mW(i) = min(HylidImage.info.wavelength(band_clusters == i));
end
[wavelengths, l] = sort(mW);
mergedData = mergedData(l, :);
mergedData = reshape(mergedData', [numRows, numCols, maxNumClusters]);

dimReductionStruct = HylidImage;
dimReductionStruct.band_clusters = band_clusters;
dimReductionStruct.Data = mergedData;
dimReductionStruct.info.wavelength = wavelengths;
if(iscell(dimReductionStruct.info.description))
        dimReductionStruct.info.description{end+1}.Detector = ['Hierarchical Dim. Reduction Output ',  datestr(clock)];
        dimReductionStruct.info.description{end}.DetectorParameters = Parameters;
else
        temp = dimReductionStruct.info.description;
        dimReductionStruct.info.description = [];
        dimReductionStruct.info.description{1} = temp;
        dimReductionStruct.info.description{2}.Detector = ['Hierarchical Dim. Reduction  Output ',  datestr(clock)];
        dimReductionStruct.info.description{2}.DetectorParameters = Parameters;
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
