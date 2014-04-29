function [parameters] = PCBootstrapSPICEParameters()

% PCBootstrapSPICEParameters code create the parameters structure for the
% PCBootstrapSPICE code. 
%
% Syntax: [parameters] = PCBootstrapSPICEParameters()
%
% Inputs:
%   None
%
% Outputs:
%   parameters - struct - This parameters structure can be created using
%   PCBoostrapSPICEParameters.m
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

%PCBootstrapSPICE Parameters
parameters.SPICERepeatNum = 100; %Number of times to run the SPICE algorithm each iteration

%%
%PCOMMEND Related Parameters
parameters.PC.alpha = 0.0001;    %Regularization parameter to trade off between volume and error (Larger values put more weight on volume/noise and less on error)
parameters.PC.changeThresh = 1e-5; %Stopping criterion change threshold (Larger values will stop the algorithm sooner, possibly prematurely if too large)
parameters.PC.M = 3;   %Number of endmembers estimated per partition (not used for final endmember distribution, only for initial partitioning)
parameters.PC.iterationCap = 1000; %Stopping criterion, Maximum number of iterations if change threshold is not reached
parameters.PC.C = 2; %Number of partitions
parameters.PC.m = 2; %Fuzzifier used to determine the amount of overlap between partitions
parameters.PC.produceDisplay = 0; %Flag to produce display during the PCOMMEND step

%%
%SPICE Related Parameters
parameters.SPICE.u = 0.0001; %Trade-off parameter between RSS and V term
parameters.SPICE.gamma = 1; %Sparsity parameter
parameters.SPICE.M = 20; %Initial number of endmembers
parameters.SPICE.endmemberPruneThreshold = 1e-9; %Threshold to determine when to remove superfluous endmembers
parameters.SPICE.changeThresh = 1e-4; %Used as the stopping criterion
parameters.SPICE.iterationCap = 5000; %Alternate stopping criterion
parameters.SPICE.produceDisplay = 0; %Flag to produce display during the SPICE step
parameters.SPICE.initEM = nan; %This randomly selects parameters.M initial endmembers from the input data

%%
%CA Related Parameters
parameters.CA.eta_0 = 5; %Parameter which controls the number of endmember distributions estimate
parameters.CA.tau = 10; %Parameter which controls the number of endmember distributions estimate
parameters.CA.Cmax = 10; %Maximum number of endmember distributions allowed
parameters.CA.pruneThresh = 1e-10; %Threshold to determine when to remove superfluous endmember distributions
parameters.CA.changeThresh = 1e-10; %Used as the stopping criterion
parameters.CA.iterationCap = 5000; %Used as the stopping criterion

%Additional Parameters
parameters.PC.EPS=.000001; 
parameters.SPICE.options = optimset('Display', 'off');
parameters.SPICE.sum_to_one = true; % if true, constrains proportions to sum to one, otherwise sum constrained to <= 1
parameters.SPICE.reflectance_ems = false;  % if true, uses quadratic programming to solve for endmembers constrained to be in [0-1]

