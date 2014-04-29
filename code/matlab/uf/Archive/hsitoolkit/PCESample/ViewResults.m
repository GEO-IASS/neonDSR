function ViewResults(InputData, Parameters, SampleTrace, FullImage)
%%
% View results of PCE Sampling Code
%
% Syntax: ViewResults(InputData, Parameters, SampleTrace, FullImage)
%
% Inputs:
%   InputData           -   NxM matrix of N data points of
%                           dimensionality M (i.e. Each data point is a row vector.)
%                           This should be the same data used to generate
%                           SampleTrace in PCESample.m
%   SampleTrace         -   SampleTrace structure that is returned from PCESample.m
%   Parameters          -   Parameters structure used to generate
%                           SampleTrace results
%   LogLikelihoodTrace  -   Matrix of log likelihood values returned from
%                           PCESample.m
%   FullImage           -   RxCxM hyperspectral data cube to be unmixed
%                           using the endmember sets in SampleTrace
% Outputs:
%   None
%   
% Author(s): Alina Zare
% University of Missouri, Electrical and Computer Engineering Department
% Email Address: zarea@missouri.edu
% Created: May 18, 2011
% Latest Revision: December 13, 2011
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

subsampleValue = 1;

rn    = zeros(1, length(SampleTrace));
for i =  1:length(SampleTrace)
    if(~isempty(SampleTrace(i).ClusterSizeFrequency))
        rn(i) = SampleTrace(i).ClusterSizeFrequency;
    end
end
figure(400); bar(rn);

[maxV, maxL] = max(rn); %Determine cluster size with the most samples
E = SampleTrace(maxL).E;
L = SampleTrace(maxL).L;
C = SampleTrace(maxL).C;
P = SampleTrace(maxL).P;
EPriorMean = SampleTrace(maxL).EPriorMean;

%Labeled Scatter Plot
if(size(InputData, 2) == 2)
    figure(200);
    scatter3(InputData(1:subsampleValue:end,1), InputData(1:subsampleValue:end,2), 30, L, 'filled'); hold on; title('Labeled Scatterplot');
    for i = 1:size(E,3)
        scatter3(E(:,1,i), E(:,2,i), 500, 'filled'); 
    end
elseif(size(InputData,2) == 3)
    figure(100); hold off;
    scatter3(InputData(1:subsampleValue:end,1), InputData(1:subsampleValue:end,2), InputData(1:subsampleValue:end,3), 30, L, 'filled'); title('Labeled Scatterplot'); hold on;

    figure(200); hold off;
    scatter3(InputData(1:subsampleValue:end,1), InputData(1:subsampleValue:end,2), InputData(1:subsampleValue:end,3), 30, L, 'filled'); title('Labeled Scatterplot'); hold on;
    for i = 1:size(E,3)
        scatter3(E(:,1,i), E(:,2,i),E(:,3,i), 500, 'filled'); 
    end
    [LogLikelihoodAll] = ComputeLogLikelihoodAll(InputData, E, P, Parameters, size(InputData,1));
    for i = 1:size(E,3)
        figure(200+i); hold off;
        scatter3(InputData(1:subsampleValue:end,1), InputData(1:subsampleValue:end,2), InputData(1:subsampleValue:end,3), 30, LogLikelihoodAll(:,i), 'filled'); hold on;
        scatter3(E(:,1,i), E(:,2,i),E(:,3,i), 500, 'filled'); 
    end
   %     figure(300); hold off;
%     scatter3(InputData(1:subsampleValue:end,1), InputData(1:subsampleValue:end,2), InputData(1:subsampleValue:end,3), 5, L, 'filled'); hold on;
%     for i = 1:size(ClusteringResults.ClusterMeans)
%         [U,S,V] = svd(ClusteringResults.ClusterCovariances(:,:,i));
%         M = ClusteringResults.ClusterMeans(i,:);
%         scatter3(M(1), M(2), M(3), ClusteringResults.ClusterCounts(i));
%         for i = 1:size(U,2)
%             p1 = [M; M + sqrt(S(i,i))*U(i,:)];
%             p2 = [M; M - sqrt(S(i,i))*U(i,:)];
%             plot3(p1(:,1), p1(:,2), p1(:,3), 'r', 'Linewidth', 3');
%             plot3(p2(:,1), p2(:,2), p2(:,3), 'r', 'Linewidth', 3');
%         end
%     end
else
    m = mean(InputData);
    [t, PCAresults] = princomp(InputData);
    IList = PCAresults(:, 1:3);
    figure(200);
    scatter3(IList(1:subsampleValue:end,1), IList(1:subsampleValue:end,2), IList(1:subsampleValue:end,3), 30, L(1:subsampleValue:end), 'filled'); title('Labeled Scatterplot'); hold on;
    for i = 1:size(E,3)
        EE = (E(:,:,i) - repmat(m, [size(E(:,:,i),1), 1]))*t;
        scatter3(EE(:,1), EE(:,2), EE(:,3), 500, 'filled'); 
    end
end

if(nargin > 3)
    %Labeled Map
    ImageList = reshape(FullImage, [size(FullImage,1)*size(FullImage,2), size(FullImage,3)]);
    Pfull = zeros(size(FullImage,1)*size(FullImage,2), size(E,1));
    for i = 1:size(E,3)
        Pfull(:,:,i) = unmix2(ImageList', E(:,:,i)');
        RSS(:,i) = sum((ImageList - Pfull(:,:,i)* E(:,:,i)).*(ImageList - Pfull(:,:,i)* E(:,:,i)),2);
    end
    Rimg = reshape(RSS, [size(FullImage,1), size(FullImage,2), size(E,3)]);
    [v l] = min(Rimg, [], 3);
    for i = 1:size(RSS,2)
        figure(300+i);
        imagesc(log(Rimg(:,:,i))); title('Residual Error Map, Low is good');
    end
    for i= 1:size(Pfull,3)
        Pimg = reshape(Pfull(:,:,i), [size(FullImage,1) size(FullImage,2) size(squeeze(Pfull(:,:,i)),2)]);
        figure;
        for j = 1:size(Pfull,2)
            subplot(1,size(Pfull,2),j); imagesc(Pimg(:,:,j).*(l == i), [0 1]);
        end
    end
end

end

function [LogLikelihoodAll] = ComputeLogLikelihoodAll(X, E, P, Parameters, NumPoints)
NumSets = size(E,3);
LogLikelihoodAll = zeros(NumPoints, NumSets);
C = (-1/2)*1./sum(P.*P*Parameters.ECovariance,2);
N = -1*log(2*pi)*(size(X,2)/2) + -1*log(squeeze(sum(P.*P*Parameters.ECovariance,2)).*size(X,2));
for i = 1:NumSets
    Recon = P(:,:,i)*E(:,:,i);
    D = (X - Recon)';
    D = sum(D.*D);
    LogLikelihoodAll(:,i) = N(:,i) + C(:,1,i).*D';
end
end
