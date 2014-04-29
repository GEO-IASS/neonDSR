function [Parameters] = generateSimulatedDataParameters(BetaParameters)

%This will always generate data that are linear combinations of two betas
%   (2 endmembers), So, don't modify the next line.
Parameters.N = 50;  %number of data points
Parameters.numNeighbor = 10; %number of neighbors
Parameters.noiseScale = 0.001;
[Parameters.D, ~, Parameters.M] = size(BetaParameters);
Parameters.BetaParameters = BetaParameters;
if(Parameters.M ~= 2);
    disp('Error');
    Parameters = [];
end

Parameters.alpha =  [ 5 1 ; 1 5 ]; %Dirichlet parameters, Number of rows is the number of data groups. 
Parameters.dgW = [.5 .5];

if(sum(Parameters.dgW) ~= 1 || length(Parameters.dgW) ~= size(Parameters.alpha, 1))
    error('error, invalid parameter set');
    Parameters = [];
end

