
function Parameters = betaCombCodeParameters()

%%
%Parameters
Parameters.display = 0;

Parameters.N = 50000; 
Parameters.M = 2;
Parameters.alpha = 1*ones(1,Parameters.M);
Parameters.histBins = [0:.01:1];

Parameters.BetaA = [1, 1];
Parameters.BetaB = [1, 1];
