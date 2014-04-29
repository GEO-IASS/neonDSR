function [Parameters] = CreateROCKYParameters()

%   This function sets the parameters to be used by the accompanying RX code
%
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

Parameters.algorithmName = 'CreateROCKY_Version1';

%Flag to save Previous image structure
Parameters.savePrevious = 1;
Parameters.saveFilePathPrevious = '/Users/zarea/Documents/MATLAB/Data/HYLID/Results/';

%Flag to resulting image structure
Parameters.saveResult = 1;
Parameters.saveFilePathResult = '/Users/zarea/Documents/MATLAB/Data/HYLID/Results/';

Parameters.Halo = 1; %Halo Radius in Meters (from center of target)

% Target filter for scoring:
%
% [] - no restriction, all targets scored
%
% otherwise, cell array of {type,size,human_conf,human_cat} tuples
%  type - [] specifies all types, otherwise give a string for target type
%  size - [] all sizes, otherwise select from [.5 1 3 6]
%                        for the .5m^2, 1m^2, 3m^2, and 6mx10m targets
%  human_conf - [] all location confidence categories, otherwise select from [1 2 3 4]
%              1 visible, 2 probably visible, 3 possibly visible, 4 not visible
%  human_cat - [] all occlusion categories, otherwise select from [0 1 2]
%                0 unoccluded, 1 part or fully in shadow but no tree occlusion, 2 part or full occlusion by tree                
%

Parameters.targetFilter = []; 

