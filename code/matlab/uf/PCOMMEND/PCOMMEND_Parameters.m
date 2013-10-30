function [parameters] = PCOMMEND_Parameters()

%   This function sets the parameters to be used during the multi model ICE algorithm
%   parameters - struct - The struct contains the following fields:
%                   1. alpha : Regularization Parameter to trade off
%                   between the RSS and V terms.
%                   2. changeThresh: Stopping Criteria, Change threshold
%                       for Objective Function.
%                   3. M: Number of endmembers per cluster.
%                   4. iterationCap: Maximum number of iterations.
%                   5. C: Number of clusters.
%                   6. m: Fuzzifier.
%                   7. EPS: small positive constant . 


    parameters.alpha = 0.001;
    parameters.changeThresh = 1e-5;
    parameters.M = 2;
    parameters.iterationCap = 1500;
    parameters.C = 4;
    parameters.m = 2;
    parameters.EPS=.000001;