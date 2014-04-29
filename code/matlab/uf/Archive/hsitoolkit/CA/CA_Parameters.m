function [parameters] = CA_Parameters()

%   This function sets the parameters to be used during the CA 
%   algorithm
%   parameters - struct - The struct contains the following fields:


%%
    parameters.eta_0 = 3;
    parameters.tau = 5;
    parameters.Cmax = 10;
    
    parameters.pruneThresh = 1e-10;
    parameters.changeThresh = 1e-10;
    parameters.M = 3;
    parameters.iterationCap = 5000;
