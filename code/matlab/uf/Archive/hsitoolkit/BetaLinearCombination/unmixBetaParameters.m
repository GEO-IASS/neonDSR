function [Parameters] = unmixBetaParameters(BetaParameters)

Parameters.methodFlag = 2;
Parameters.BetaParameters = BetaParameters;
Parameters.D = size(BetaParameters,1);
Parameters.M = size(BetaParameters,3);
Parameters.K = 12;
Parameters.NumIterations = 10000;
Parameters.sigV = 100;
Parameters.sigM = .001;
