function [parameters] = PFCMPCE_Batch_Parameters()

% PFCMPCE_Parameters : Piece-wise Convex Spatial-Spectral Unmixing of Hyperspectral Imagery using Possibilistic and Fuzzy Clustering
%   This can be used to set up the parameters structure for the
%   PFCMPCE code.
% Syntax: [parameters] = PFCMPCE_Parameters();
%
% Inputs: none
% Outputs:
%   parameters - struct
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


    parameters.alpha = 0.001;  %Weight used to trade off between residual error & volume terms, smaller = more weight on error
    parameters.a = 20; %Weight on membership value in first term of the objective
    parameters.b = .1; %Weight on typicality value in first term of the objective
    parameters.changeThresh = 1e-6; %Stopping criterion, When change drops below this threshold the algorithm stops
    parameters.M = 3; %Number of Endmembers Per Convex Region
    parameters.iterationCap = 1000; %Iteration cap, used to stop the algorithm
    parameters.C = 2; %Number of Convex Regions
    parameters.m = 2; %Fuzzifier for the memberships
    parameters.n = 1.5; %Exponent for the typicality value
    parameters.EPS=.000001; % Parameter used to diagonally load some matrices in the code
    parameters.sizeWindow = [5 5];  %Neighborhood Window Size for Spatial Processing / FLICM algorithm parameter, larger = more spatial smoothing
    
    %%% BATCH PARAMETERS %%%
    parameters.NumEndMemRange = [2 3 4 5 6];%MIGHT WANT TO CHANGE SO THAT IF NUMBER OF ENDMEMBERS IS 1, THEN WE JUST CLUSTER THE DATA
    parameters.NumClustsRange = [1 2 3 4];
    parameters.NumInits       = 20;
    parameters.NumExps        = parameters.NumInits*length(parameters.NumClustsRange)*length(parameters.NumEndMemRange);
    
    