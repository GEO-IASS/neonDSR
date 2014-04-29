function [L, C, V] = EMGaussianCluster(InputData, NumClusters)
%%
% EM Clustering with Gaussian Mixtures with a Full Covariance
%
% Syntax: [L, C, V] = EMGaussianCluster(InputData, NumClusters)
%
% Inputs:
%   InputData   -   NxM matrix of N data points of
%                   dimensionality M (i.e. Each data point is a row vector.)
%   NumClusters -   Desired number of clusters
%
% Outputs:
%   L           -   Vector of clusters labels for each data point, Label is
%                   determined by assigning each data point to the cluster
%                   with the highest P(Cj|xi)
%   C           -   RxM matrix of R Gaussian cluster means with
%                   dimensionality M
%   V           -   MxMxR matrix of R full covariance matrices for each
%                   Gaussian cluster of size MxM
%
% Author(s): Alina Zare
% University of Missouri, Electrical and Computer Engineering Department
% Email Address: zarea@missouri.edu
% Created: May 17, 2011
% Latest Revision: May 31, 2011
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
%Initilize Clusters & Constants
[L, C] = kmeans(InputData,NumClusters); %Initialize cluster means
for i = 1:NumClusters
    V(:,:,i) = cov(InputData(L == i,:)); %Initialize cluster full covariance
end
iter = 0; %Iteration Count
continueFlag = 1; %Stopping criteria flag
NumPoints = size(InputData,1); %Number of data points
NumDimensions = size(InputData,2); %Data dimensionality
condThresh = ceil(NumPoints/(10*NumClusters)); %Minimum Number Of Points In a Cluster Threshold
mixProp = 1/NumClusters * ones(1, NumClusters); %Initialize mixing proportions
convergeThresh = 1e-4;
maxNumIterations = 10000;

while(continueFlag)
    
    %Update L
    pCX = zeros(NumPoints, NumClusters);
    for i = 1:NumClusters
        try
            pCX(:,i) = mvnpdf(InputData,C(i,:),V(:,:,i)).*mixProp(ones(NumPoints,1),i);
        catch
            diff = (InputData - C(ones(NumPoints,1)*i,:));
            pCX(:,i) = ((2*pi)^(-NumDimensions/2))*(det(V(:,:,i))^(-1/2))*exp((-1/2)*diag(diff*pinv(V(:,:,i))*diff')).*mixProp(ones(NumPoints,1),i);
        end
    end
    pCX = pCX./repmat(sum(pCX')', [1, NumClusters]);
    
    %Update C
    Cprev = C;
    for i = 1:NumClusters
        C(i,:) = sum(repmat(pCX(:,i), [1, NumDimensions]).*InputData)/sum(pCX(:,i));
    end
    
    %Update V
    for i = 1:NumClusters
        diff(:,:,i) = repmat(sqrt(pCX(:,i)), [1, NumDimensions]).*(InputData - C(ones(NumPoints,1)*i,:));
    end
    for i = 1:NumClusters
        V(:,:,i) = (diff(:,:,i)'*diff(:,:,i))/sum(pCX(:,i));
    end
    
    
   %Check for Singularities
   [pCX, C, V, NumClusters] = checkCond(InputData, pCX, C, V, NumClusters, condThresh);
   if(size(C,1) ~= size(Cprev,1)); Cprev = zeros(size(C)); end;
    
    %Update Mixing Proportions
    mixProp = (1/NumPoints)*sum(pCX);
    
    %Check Stopping Criteria
    if(  norm(C - Cprev) < convergeThresh || iter > maxNumIterations || NumClusters == 1 )
        continueFlag = 0;
    end
    
    %Update Iteration Count
    iter = iter + 1;
end

[maxV, L] = max(pCX, [], 2);

end


function [pCX, C, V, NumClusters] = checkCond(InputData, pCX, C, V, NumClusters, condThresh);

[maxV, L] = max(pCX, [], 2);
rFlag = zeros(1, NumClusters);
for i = 1:NumClusters
    numP = sum(L == i);
    if(numP < condThresh || isnan(cond(V(:,:,i))))
        rFlag(i) = numP;
    end
end
if(sum(rFlag) > 0)
    if(sum(rFlag) > 1)
        keyboard;
    else
        rFlag = logical(rFlag ~=0);
    end
    NumClusters = NumClusters - 1;
    C = C(rFlag, :);
    V = V(:,:, rFlag);
    pCX = pCX(:, rFlag);
end
end