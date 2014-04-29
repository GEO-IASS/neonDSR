function Parameters = MCPCE_Parameters()

%% Parameters
basepath = 'C:\Users\tjaty8\Documents\MATLAB\HSItoolkit\'; 
addpath(fullfile(basepath, 'PFCM_FLICM_PCE'));
addpath(fullfile(basepath, 'fast_spice'));
addpath(fullfile(basepath, 'fast_spice\qpc'));
addpath(fullfile(basepath, 'CA'));


Parameters.SPICE_Iterations = 3;

PFCMPCE_Params.alpha = 0.01;  %Weight used to trade off between residual error & volume terms, smaller = more weight on error
PFCMPCE_Params.a = 20; %Weight on membership value in first term of the objective
PFCMPCE_Params.b = .1; %Weight on typicality value in first term of the objective
PFCMPCE_Params.changeThresh = 1e-6; %Stopping criterion, When change drops below this threshold the algorithm stops
PFCMPCE_Params.M = 3; %Number of Endmembers Per Convex Region
PFCMPCE_Params.iterationCap = 1000; %Iteration cap, used to stop the algorithm
PFCMPCE_Params.C = 2; %Number of Convex Regions
PFCMPCE_Params.m = 1.1; %Fuzzifier for the memberships
PFCMPCE_Params.n = 1.5; %Exponent for the typicality value
PFCMPCE_Params.EPS=.000001; % Parameter used to diagonally load some matrices in the code
PFCMPCE_Params.sizeWindow = [1 1];  %Neighborhood Window Size for Spatial Processing / FLICM algorithm parameter, larger = more spatial smoothing
Parameters.PFCMPCE_Params = PFCMPCE_Params;

SPICE_Params.u = 0.0001; %Trade-off parameter between RSS and V term
SPICE_Params.gamma = 1; %Sparsity parameter
SPICE_Params.M = 20; %Initial number of endmembers
SPICE_Params.endmemberPruneThreshold = 1e-9;
SPICE_Params.changeThresh = 1e-4; %Used as the stopping criterion
SPICE_Params.iterationCap = 5000; %Alternate stopping criterion
SPICE_Params.produceDisplay = 0;
SPICE_Params.initEM = nan; %This randomly selects parameters.M initial endmembers from the input data
SPICE_Params.options = optimset('Display', 'off');
Parameters.SPICE_Params = SPICE_Params;

CA_Params.eta_0 = 3;
CA_Params.tau = 5;
CA_Params.Cmax = 10;
CA_Params.pruneThresh = 1e-10;
CA_Params.changeThresh = 1e-10;
CA_Params.M = 3;
CA_Params.iterationCap = 5000;
Parameters.CA_Params = CA_Params;

