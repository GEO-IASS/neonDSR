function [E, C, U] = PCBootstrapSPICE(X, Parameters)

% PCBootstrapSPICE code to estimate multiple sets of endmember
% distributions
%
% Syntax: [E, C, U] = PCBootstrapSPICE(X, Parameters)
%
% Inputs:
%   X - double Mat - NxM matrix of N data points of
%       dimensionality M 
%   parameters - struct - This parameters structure can be created using
%       PCBoostrapSPICEParameters.m
%
% Outputs:
%   E - Cell Array - Each element of the cell array contains an NxD matrix 
%       of N endmembers means with D spectral bands
%   C - Cell Array Mat - DxDxM matrix of covariance matrices
%   U - double Mat - NxC fuzzy partition matrix providing the partitioning
%       of the data into corresponding endmember sets
%
% Author:  Alina Zare
% University of Missouri, Electrical and Computer Engineering
% Email Address: zarea@missouri.edu
% Latest Revision: January 17, 2013
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
% THIS SOFTWARE IS PROVIDED BY THE UNIVERSITIES OF MISSOURI AND FLORIDA AND
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

addpath('./qpc');

%Apply PCOMMEND
disp('Running PCOMMEND...');
[~,~,U,~]=PCOMMEND(X,Parameters.PC);

%Assign Data Points
disp('Assigning Data Points...');
[~, Labels] = max(U);
for i = 1:size(U,1)
    x{i} = X(Labels == i, :);
end

disp('Running SPICE...');
%Apply SPICE Repeatedly
for i = 1:size(U,1)
    fprintf(' \n');
    disp(['Running SPICE for Partition ', num2str(i), ' of ', num2str(size(U,1))]);
    e{i} = [];
    fprintf('SPICE Run of %i:\n', Parameters.SPICERepeatNum);
    for j = 1:Parameters.SPICERepeatNum
         fprintf('%i, ', j);
        [endmembers, ~] = SPICE(x{i}', Parameters.SPICE);
        e{i} = horzcat(e{i}, endmembers);
    end
end
clear endmembers; 

fprintf(' \n');
disp('Apply CA...');
%Apply CA
for i = 1:size(U,1)
    [ee,uu,~] = CA(e{i}',Parameters.CA);
    numE = size(ee,1);
    [~, ll] = max(uu, [], 2);
    for j = 1:numE
        if(sum(ll == j) > 1)
            E{i}(j,:) = mean(e{i}(:,ll == j)');
            C{i}(:,:,j) = cov(e{i}(:, ll == j)');
        else
            E{i}(j,:) = e{i}(:,ll == j)';
            C{i}(:,:,j) = cov(e{i}(:, ll == j)')*eye(size(e{i},1));
        end
    end
end

