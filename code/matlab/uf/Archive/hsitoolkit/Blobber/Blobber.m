function [BlobStruct] = Blobber(ConfImage, Parameters)

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
    X = ConfImage.Data;

catch
    error('Input Image must be in the Hylid Image Format');
end
numRows = size(X,1);
numCols = size(X,2);
numDims = size(X,3);


%Save Previous Image Structure
if(Parameters.savePrevious)
    filename = fullfile(Parameters.saveFilePathPrevious, strcat(Parameters.algorithmName, 'PREVIOUS_', datestr(clock, 'yyyy_mm_dd__HH_MM_SS'), '.mat'));
    save(filename, 'ConfImage');
end


if(isempty(Parameters.Threshold))
    %Use Otsu's Threshold
    X = X/max(X(:));
    Parameters.Threshold = graythresh(X);
end

%Threshold Image
Xt = (X>Parameters.Threshold).*X;

%Morphology
se = strel('disk', Parameters.SERadius);
Xt = imclose(Xt, se);

%Find Connected Components
Xl = bwlabel(Xt);

%Create Alarm Structure
Alarms = regionprops(Xl, X, 'pixellist', 'pixelvalues', 'WeightedCentroid', 'MaxIntensity');

BlobStruct = ConfImage;
BlobStruct.Data = Xt;
BlobStruct.Alarms = Alarms;

for i = 1:length(Alarms)
    r = max(round(Alarms(i).WeightedCentroid), 1);
    r(1) = min(r(1), numCols);
    r(2) = min(r(2), numRows);
    BlobStruct.Alarms(i).utm_x = BlobStruct.Easting(r(1));
    BlobStruct.Alarms(i).utm_y = BlobStruct.Northing(r(2));
    BlobStruct.Alarms(i).confidence = BlobStruct.Alarms(i).MaxIntensity;
    BlobStruct.Alarms(i).row = r(2);
    BlobStruct.Alarms(i).col = r(1);
end
BlobStruct.Alarms = rmfield(BlobStruct.Alarms,'WeightedCentroid');
BlobStruct.Alarms = rmfield(BlobStruct.Alarms,'MaxIntensity');

if(iscell(BlobStruct.info.description))
        BlobStruct.info.description{end+1}.CreateAlarms = ['Blobber Output ',  datestr(clock)];
        BlobStruct.info.description{end}.CreateAlarmsParameters = Parameters;
else
        temp = BlobStruct.info.description;
        BlobStruct.info.description = [];
        BlobStruct.info.description{1} = temp;
        BlobStruct.info.description{2}.CreateAlarms = ['Blobber Output ',  datestr(clock)];
        BlobStruct.info.description{2}.CreateAlarmsParameters = Parameters;
end

if(Parameters.writeELE)
    filename = fullfile(Parameters.saveFilePathELE, strcat(Parameters.algorithmName, datestr(clock, 'yyyy_mm_dd__HH_MM_SS'), '.ele'));
    fid = fopen(filename, 'w');
    fprintf(fid, 'Row\t Col\t Northing\t Easting\t Confidence\n' );
    for i = 1:length(Alarms)
        fprintf(fid, '%6.0f\t %6.0f\t %6.0f\t %6.0f\t %6.2f\n', [BlobStruct.Alarms(i).row, BlobStruct.Alarms(i).col,  BlobStruct.Alarms(i).utm_y, BlobStruct.Alarms(i).utm_x, BlobStruct.Alarms(i).confidence] );
    end
    fclose(fid);
end

if(Parameters.saveResult)
    filename = fullfile(Parameters.saveFilePathResult, strcat(Parameters.algorithmName, datestr(clock, 'yyyy_mm_dd__HH_MM_SS'), '.mat'));
    save(filename, 'BlobStruct');
end


end
