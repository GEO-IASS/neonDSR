function [E,P,U,T]=PFCMPCEHL(HInputImage,LInputImage, parameters)

% PFCMPCEHL : Piece-wise Convex Spatial-Spectral Unmixing of Hyperspectral Imagery using LiDAR elevation and Possibilistic and Fuzzy Clustering
%
% Syntax: [E,P,U,T] = PFCMPCEHL(InputHImage,InputLImage, parameters)
%
% Inputs:
%   HInputImage - Hyperspectral Image - double Mat - NxMxD matrix, an NxM image with
%   dimensionality D for each feature vector
%   LInputImage - LiDAR elevation image with first and last return - stored
%   as a cell array
%   LInputImage - parameters - struct - parameter structure which can be set using the
%   PFCMPCEHL_Parameters() function
%
% Outputs:
%   E - Endmembers
%   P - Proportion Values
%   U - Membership Values
%   T - Typicality Values
%
%
% Author: Alina Zare, Paul Gader = Paulina Zader
% University of Missouri, Electrical and Computer Engineering Department
% Email Address: zarea@missouri.edu
% Created: January 5, 2011
% Latest Revision: October 22, 2011
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

HX  = reshapeImage(HInputImage)';    %HYPERSPECTRAL IMAGE
FR  = LInputImage{1}.z;              %FIRST RETURN OF LiDAR, elevation and intensity
FRE = squeeze(FR(:, :, 1));          %FIRST RETRUN OF LiDAR, elevation
LR  = LInputImage{1}.z;              %LAST  RETURN OF LiDAR, elevation and intensity
LRE = squeeze(LR(:, :, 1));          %LAST  RETRUN OF LiDAR, elevation
dM  = createDistanceMatrixHL(parameters.sizeWindow, HInputImage, FRE, LRE);

% Initialization
[E,U,T] = PFCMPCE_Initialize(HX,parameters);
obj_func=inf;

for iter=1:parameters.iterationCap 
    iter
    %Update abundance
    P=P_update(HX,E,parameters.C,parameters.EPS);
    %Update Endmembers
    E=E_update(U,T,P,HX, parameters);
    %Update fuzzy membership
    U=U_update( InputImage, HX,P,E,U,parameters.m,parameters.EPS, dM);
    %Update Typicality
    T=T_update(HX,P,E,T,parameters);
    
    [Cond, obj_func]=Cond_update(obj_func,HX,P,E,U,T,parameters);
    Cond
    if(Cond <parameters.changeThresh)   
        break;
    end   
end


function dM = createDistanceMatrixHL(NghdSize, FRE, LRE)
%Variable Definitions
center   = NghdSize/2;
c1       = center(1);
c2       = center(2);
NghdRows = size(center, 1);
NghdCols = size(center, 2);
NRows    = size(FRE, 1);
NCols    = size(FRE, 2);
SRow     = center;
ERow     = NRows - center + 1;
SCol     = center;
ECol     = NCols - center + 1;
dM       = cell(NRows, NCols);
Nghd     = zeros(NghdSize, NghdSize);

%GET DISTANCES TO LIDAR NEIGHBORS
%MAY BE ABLE DO THIS BY VECTORIZING, COMPUTING ALL THE PAIRWISE DISTANCES,
%AND UNVECTORIZING

for Row = SRow:ERow
    for Col = SCol:ECol
        ElevationsRowCol = [FRE(Row, Col), LRE(Row, Col)];                          %1x2
        for i = 1:NghdRows;
            for j = 1:NghdCols;
                Elevationsij = [FRE(Row+c1-i, Col+c2-j); LRE(Row+c1-i, Col+c2-j)];  %2x1
                AllDists     = dist(Elevationsij, ElevationsRowCol);                %2x2
                LiDARDist    = mean(min(AllDists));                                 
                LiDARDistSq  = LiDARDist.*LiDARDist;
                IndexDistSq  = (c1 -i)^2 + (c2-j)^2;
                Nghd(i,j)    = 1./1+sqrt(LiDARDistSq+IndexDistSq);
            end
        end
        dM{r,c} = Nghd;
    end
end