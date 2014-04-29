function [ROCKYStruct] = CreateROCKY(BlobImage, Parameters)
%function [ROCKYStruct] = CreateROCKY(BlobImage, Parameters)

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

%Save Previous Image Structure
if(Parameters.savePrevious)
    filename = fullfile(Parameters.saveFilePathPrevious, strcat(Parameters.algorithmName, 'PREVIOUS_', datestr(clock, 'yyyy_mm_dd__HH_MM_SS'), '.mat'));
    save(filename, 'BlobImage');
end

% determine which alarms to score
gt = BlobImage.groundTruth;

filt = Parameters.targetFilter;
n_targets = numel(gt.Targets_ID);

score_list = false(1,n_targets);
for i=1:n_targets
    score_list(i) = matches_filter(filt,gt.Targets_Type{i},gt.Targets_Size(i),gt.Targets_HumanConf(i),gt.Targets_HumanCat(i));           
end

% remove unscored targets from the truth
fields = fieldnames(gt);
for i=1:numel(fields)
    gt.(fields{i})(~score_list) = [];
end

%Determine Area
area = abs(((BlobImage.Easting(end) - BlobImage.Easting(1))*BlobImage.info.map_info.dx)*((BlobImage.Northing(end) - BlobImage.Northing(1))*BlobImage.info.map_info.dy));

%Sort Alarms
c = [BlobImage.Alarms.confidence];
[v, alarmOrder] = sort(c, 'descend');
ROCKYStruct = BlobImage;
ROCKYStruct = rmfield(ROCKYStruct, 'Alarms');

ROCKYStruct.filteredTruth = gt;
ROCKYStruct.targetFilter = Parameters.targetFilter;

FAR = 0;
PD = 0;
ROCKYStruct.ROCKY = [];
k = 1;

TargetFound = zeros(1, length(gt.Targets_Size));

%Get Alarm UTMs
AlarmRC(:,1) = [BlobImage.Alarms.utm_x];
AlarmRC(:,2) = [BlobImage.Alarms.utm_y];
AlarmRC = AlarmRC(alarmOrder,:);
numAlarms = size(AlarmRC,1);

%Get Target UTMs
TargetRC(:,1) = gt.Targets_UTMx;
TargetRC(:,2) = gt.Targets_UTMy;
numTargets = size(TargetRC,1);

%Compute pairwise distances
D = zeros(numAlarms, numTargets);
for i = 1:numTargets
    diff(:,:,i) = AlarmRC - repmat(TargetRC(i,:), [numAlarms, 1]);
    diff(:,:,i) = diff(:,:,i).*diff(:,:,i);
    D(:,i) = sqrt(sum(diff(:,:,i), 2));
end

[dists, targetHit] = min(D, [], 2);
targetHit = (dists <= Parameters.Halo).*targetHit;
dists = (dists <= Parameters.Halo).*dists;

for i = alarmOrder
     ROCKYStruct.ROCKY{k,1} = c(i);
     
     if(targetHit(k) == 0)
         %false alarm
         ROCKYStruct.ROCKY{k,2} = PD/numTargets;
         FAR = FAR + 1;
         ROCKYStruct.ROCKY{k,3} = FAR/area;
         ROCKYStruct.ROCKY{k,4} = 'False Alarm';
         ROCKYStruct.ROCKY{k,5} = BlobImage.Alarms(i).row;
         ROCKYStruct.ROCKY{k,6} = BlobImage.Alarms(i).col;
         ROCKYStruct.ROCKY{k,7} = 'nan';
         ROCKYStruct.ROCKY{k,8} = 'nan';
     else
         %hit on target
         if(TargetFound(targetHit(k)))
             %target was previously found, do not increase PD or FAR
             ROCKYStruct.ROCKY{k,2} = PD/numTargets;
             ROCKYStruct.ROCKY{k,3} = FAR/area;
             tt = strcat(gt.Targets_Type(targetHit(k)), '_', num2str(gt.Targets_Elevated(targetHit(k))), '_', num2str(gt.Targets_Size(targetHit(k))), '_', gt.Targets_ID(targetHit(k)));  
             ROCKYStruct.ROCKY{k,4} = strcat('Previously Detected Target ', tt );
             ROCKYStruct.ROCKY{k,5} = BlobImage.Alarms(i).row;
             ROCKYStruct.ROCKY{k,6} = BlobImage.Alarms(i).col;
             ROCKYStruct.ROCKY{k,7} = 'tbfi';
             ROCKYStruct.ROCKY{k,8} = 'tbfi';
         else
             TargetFound(targetHit(k)) = 1;
             %new target found, increase PD
             PD = PD+1;
             ROCKYStruct.ROCKY{k,2} = PD/numTargets;
             ROCKYStruct.ROCKY{k,3} = FAR/area;
             tt = strcat(gt.Targets_Type(targetHit(k)), '_', num2str(gt.Targets_Elevated(targetHit(k))), '_', num2str(gt.Targets_Size(targetHit(k))), '_', gt.Targets_ID(targetHit(k)));  
             ROCKYStruct.ROCKY{k,4} = tt;
             ROCKYStruct.ROCKY{k,5} = BlobImage.Alarms(i).row;
             ROCKYStruct.ROCKY{k,6} = BlobImage.Alarms(i).col;
             ROCKYStruct.ROCKY{k,7} = 'tbfi';
             ROCKYStruct.ROCKY{k,8} = 'tbfi';
         end
     end
    k = k + 1;
end


if(iscell(ROCKYStruct.info.description))
        ROCKYStruct.info.description{end+1}.CreateAlarms = ['ROCKY Output ',  datestr(clock)];
        ROCKYStruct.info.description{end}.CreateAlarmsParameters = Parameters;
else
        temp = ROCKYStruct.info.description;
        ROCKYStruct.info.description = [];
        ROCKYStruct.info.description{1} = temp;
        ROCKYStruct.info.description{2}.CreateROC = ['ROCKY Output ',  datestr(clock)];
        ROCKYStruct.info.description{2}.CreateROCParameters = Parameters;
end

if(Parameters.saveResult)
    filename = fullfile(Parameters.saveFilePathResult, strcat(Parameters.algorithmName, datestr(clock, 'yyyy_mm_dd__HH_MM_SS'), '.mat'));
    save(filename, 'ROCKYStruct');
end


end
