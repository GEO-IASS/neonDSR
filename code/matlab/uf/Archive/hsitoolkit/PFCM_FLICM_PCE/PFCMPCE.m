function [E,P,U,T]=PFCMPCE(InputImage,params,mask)

% PFCMPCE : Piece-wise Convex Spatial-Spectral Unmixing of Hyperspectral Imagery using Possibilistic and Fuzzy Clustering
%
% Syntax: [E,P,U,T] = PFCMPCE(InputImage, params, mask)
%
% Inputs:
%   InputImage - double Mat - NxMxD matrix, an NxM image with
%      dimensionality D for each feature vector
%   params - struct - parameter structure which can be set using the
%      PFCMPCE_Parameters() function
%   mask - binary label matrix of valid pixels, defaults to all true if not supplied
%
% Outputs:
%   E - Endmembers
%   P - Proportion Values
%   U - Membership Values
%   T - Typicality Values
%
%
% Author: Alina Zare
% University of Missouri, Electrical and Computer Engineering Department
% Email Address: zarea@missouri.edu
% Created: January 5, 2011
% Latest Revision: March 16, 2011
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

if ~exist('mask','var') || isempty(mask)
    mask = true(size(InputImage,1),size(InputImage,2));
end

allX  = reshapeImage(InputImage)';
X = allX(mask(:),:);

fprintf('Creating Distance Matrix...\n')
dM = createDistanceMatrix(params.sizeWindow);


% Initialization
fprintf('Initializing...\n');
[E,U,T] = PFCMPCE_Initialize(X,params);


obj_func=inf;

P=P_update(X,E,params.C,params.EPS);  

[eP,eU,eT] = embiggen(mask,P,U,T);
if params.plot, ViewResultsPFCMPCE(InputImage, eP, E, eU, eT); end


fprintf('Running...\n');
tic;


for iter=1:params.iterationCap 
    %Update abundance
    P=P_update(X,E,params.C,params.EPS);
    %Update Endmembers
    E=E_update(U,T,P,X, params);
    %Update fuzzy membership
    U=U_update(InputImage,mask,X,P,E,U,params.m,params.EPS, dM);
    %Update Typicality
    T=T_update(X,P,E,U,T,params);
    
    [Cond, obj_func]=Cond_update(obj_func,X,P,E,U,T,params);
    if(~mod(iter, 50))
        fprintf('iter %d \n',iter);
        toc;
        tic;
        [eP,eU,eT] = embiggen(mask,P,U,T);
        if params.plot, ViewResultsPFCMPCE(InputImage, eP, E, eU, eT); end
    end
    if(Cond < params.changeThresh)   
        break;
    end   
end
toc;

[P,U,T] = embiggen(mask,P,U,T);

end

function dM = createDistanceMatrix(sizeDM)

center = round(sizeDM/2);
dM = zeros(sizeDM);

for i = 1:sizeDM(1)
    for j = 1:sizeDM(2)
        
        dM(i,j) = 1/(1+sqrt((center(1) -i)^2 + (center(2)-j)^2));
    end    
end
dM(center(1), center(2)) = 0;

end

function [eP,eU,eT] = embiggen(mask,P,U,T)
% expands out the P,U,T matrices to have NaN values for the invalid pixels

[n_row,n_col] = size(mask);
n_pix = n_row*n_col;
n_cluster = numel(P);
M = size(P{1},2);

eP = cell(1,n_cluster);
eU = nan(n_cluster,n_pix);
eT = nan(n_cluster,n_pix);

eU(:,mask(:)) = U;
eT(:,mask(:)) = T;

for i=1:n_cluster
    eP{i} = nan(n_pix,M);
    eP{i}(mask(:),:) = P{i};
end

end
