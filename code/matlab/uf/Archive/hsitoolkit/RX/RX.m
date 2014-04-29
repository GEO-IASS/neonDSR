function [RXStruct] = RX(HylidImage, Parameters)

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
%Initialize
try
    X = HylidImage.Data;

catch
    error('Input Image must be in the Hylid Image Format');
end
numRows = size(X,1);
numCols = size(X,2);
numDims = size(X,3);


%Save Previous Image Structure
if(Parameters.savePrevious)
    filename = fullfile(Parameters.saveFilePathPrevious, strcat(Parameters.algorithmName, 'PREVIOUS_', datestr(clock, 'yyyy_mm_dd__HH_MM_SS'), '.mat'));
    save(filename, 'HylidImage');
end


%Create masks
sizeMaskSide = 2*(Parameters.bRadius + Parameters.gRadius + (Parameters.tRadius - 1)) + 1;
bMask = ones(sizeMaskSide);
bMask(Parameters.bRadius+1:sizeMaskSide-Parameters.bRadius, Parameters.bRadius+1:sizeMaskSide - Parameters.bRadius) = 0;
tMask = zeros(sizeMaskSide);
tMask(Parameters.bRadius+Parameters.gRadius+1:sizeMaskSide-Parameters.bRadius-Parameters.gRadius, Parameters.bRadius+Parameters.gRadius+1:sizeMaskSide - Parameters.bRadius - Parameters.gRadius) = 1;

%Compute Means
M = convn(X,bMask, 'same');
M = (1/sum(bMask(:))).*M;
MList = reshape(M, [numRows*numCols, numDims]);

%Reshape input data
XList = reshape(X, [numRows*numCols, numDims]);

% %Determine relative position of mask points
% bMaskLarge = zeros(numRows, sizeMaskSide);
% bMaskLarge(1:sizeMaskSide, 1:sizeMaskSide) = bMask;
% bMaskLarge = bMaskLarge(:);
% bLoc = find(bMaskLarge);
% 
% tMaskLarge = zeros(numRows, sizeMaskSide);
% tMaskLarge(1:sizeMaskSide, 1:sizeMaskSide) = tMask;
% tMaskLarge = tMaskLarge(:);
% tLoc = find(tMaskLarge);
% 
% rLoc = bLoc - tLoc; %Relative Locations
% 
% RXDetectorImage = zeros(numRows,numCols);
% validRegion = floor(sizeMaskSide/2);
% for i = tLoc:(numRows*numCols)-tLoc
%     if( mod(i, numRows) <= validRegion || numRows - mod(i,numRows) <= validRegion)
%         RXDetectorImage(i)= 0;
%     else
%         %pull out background points
%         locs = rLoc + i;
%         bX = XList(locs,:);
%         %compute Mahalanobis distance
%         covB = cov(bX);
%         d = XList(i,:) - MList(i,:);
%         RXDetectorImage(i) = d*covB*d';
%     end
% end

bin_bMask = bMask > 0;
bin_tMask = tMask > 0;

RXDetectorImage = zeros(numRows,numCols);
half_width = floor(sizeMaskSide/2);

for i=1:(numCols-sizeMaskSide)+1
    for j=1:(numRows-sizeMaskSide)+1

        bMaskLarge = false(numRows, numCols);
        bMaskLarge((1:sizeMaskSide)+j-1, (1:sizeMaskSide)+i-1) = bin_bMask;
        bMask_list = bMaskLarge(:);
        
        tMaskLarge = false(numRows, numCols);
        tMaskLarge((1:sizeMaskSide)+j-1, (1:sizeMaskSide)+i-1) = bin_tMask;
        tMask_list = tMaskLarge(:);
        
        %pull out background points        
        bX = XList(bMask_list,:);
        %compute Mahalanobis distance
        covBinv = pinv(cov(bX));
        d = XList(tMask_list,:) - MList(tMask_list,:);
        RXDetectorImage(j+half_width,i+half_width) = sum(diag(d*covBinv*d'));
                
    end
end

RXStruct = HylidImage;
RXStruct.Data = RXDetectorImage;
if(iscell(RXStruct.info.description))
        RXStruct.info.description{end+1}.Detector = ['RX Detector Output ',  datestr(clock)];
        RXStruct.info.description{end}.DetectorParameters = Parameters;
else
        temp = RXStruct.info.description;
        RXStruct.info.description = [];
        RXStruct.info.description{1} = temp;
        RXStruct.info.description{2}.Detector = ['RX Detector Output ',  datestr(clock)];
        RXStruct.info.description{2}.DetectorParameters = Parameters;
end

if(Parameters.saveResult)
    filename = fullfile(Parameters.saveFilePathResult, strcat(Parameters.algorithmName, datestr(clock, 'yyyy_mm_dd__HH_MM_SS'), '.mat'));
    save(filename, 'RXStruct');
end

end
