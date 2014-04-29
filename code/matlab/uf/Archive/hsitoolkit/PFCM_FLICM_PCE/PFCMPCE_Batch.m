function [E,P,U,T]=PFCMPCE_Batch(InputImage,parameters)

% PFCMPCE : Piece-wise Convex Spatial-Spectral Unmixing of Hyperspectral Imagery using Possibilistic and Fuzzy Clustering
%
% Syntax: [E,P,U,T] = PFCMPCE(InputImage, parameters)
%
% Inputs:
%   InputImage - double Mat - N x M x D image with
%   dimensionality D for each feature vector
%   parameters - struct - parameter structure which can be set using the
%   PFCMPCE_Parameters() function
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

PRINTOBJFUNC = 0;
OUTPUTFILE   = 'BunchesOfEndmembersFrontHylidImage1thru42.mat';

%PRE-INITIALIZATION
X = reshapeImage(InputImage)';
dM = createDistanceMatrix(parameters.sizeWindow);

NumEndMemRange = parameters.NumEndMemRange
NumClustsRange = parameters.NumClustsRange
NumInits       = parameters.NumInits;
NumExps        = parameters.NumExps;
AllTheEndMems  = struct('NumEndMems', cell(NumExps, 1), 'NumClusts', cell(NumExps, 1), 'InitIndex', cell(NumExps, 1), 'EndMembers', cell(NumExps, 1));

ExpNum = 0;
FigNum = 1000;
for NumEndMems = NumEndMemRange
    parameters.M = NumEndMems;
    for NumClusts = NumClustsRange
        parameters.C = NumClusts;
        for Init = 1:NumInits
            % Initialization
            fprintf('Number of Endmembers : %6d\n', NumEndMems);
            fprintf('Number of Clusters   : %6d\n', NumClusts);
            fprintf('Initialization Number: %6d\n', Init);
            ExpNum = ExpNum+1;
            
            tic
            [E,U,T] = PFCMPCE_Initialize(X,parameters);
            obj_func=inf;
            
            for iter=1:parameters.iterationCap
                %Update abundance
                P=P_update(X,E,parameters.C,parameters.EPS);
                %Update Endmembers
                E=E_update(U,T,P,X, parameters);
                %Update fuzzy membership
                if(NumClusts > 1)
                    U=U_update( InputImage, X,P,E,U,parameters.m,parameters.EPS, dM);
                end
                %Update Typicality
                T=T_update(X,P,E,T,parameters);
                
                %Check Stopping Condition
                [Cond, obj_func]=Cond_update(obj_func,X,P,E,U,T,parameters);
                if(PRINTOBJFUNC & ~mod(iter, 10)) fprintf('Iteration:  %5d   Change In Objective Function:  %15.9f\n', iter, Cond);end
                %if(PRINTOBJFUNC) fprintf('Iteration:  %5d   Change In Objective Function:  %15.9f\n', iter, Cond);end
                if(Cond <parameters.changeThresh)
                    break;
                end
            end
            toc
            fprintf('Saving Results of ExpNum=%5d\n',  ExpNum);
            tic
            AllTheEndMems(ExpNum).NumEndMems = NumEndMems;
            AllTheEndMems(ExpNum).NumClusts  = NumClusts;
            AllTheEndMems(ExpNum).InitIndex  = Init;
            AllTheEndMems(ExpNum).EndMembers = E;
            save(OUTPUTFILE, 'AllTheEndMems')
            toc
            FigNum       = FigNum+1;
            hold on
            for ClustNum = 1:NumClusts
                plot(E{ClustNum}')
            end
        end
    end
end


function dM = createDistanceMatrix(sizeDM)
center = round(sizeDM/2);
for i = 1:sizeDM(1);
    for j = 1:sizeDM(2);
        dM(i,j) = 1/(1+sqrt((center(1) -i)^2 + (center(2)-j)^2));
    end
    dM(center(1), center(2)) = 0;
end