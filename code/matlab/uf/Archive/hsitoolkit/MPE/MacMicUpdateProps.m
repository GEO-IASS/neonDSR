 function [P, F, Error, RSSSum] = MacMicUpdateProps(E, X, dataW, F, mu, AlbLUT, OptParams)
%function [P, F, Error, RSSSum] = MacMicUpdateProps(E, X, dataW, F, mu, AlbLUT, OptParams)
%
%
%If we make this Bayesian, then we will bring in the last set of
%proportions and the result will be an average
%
% INPUTS
% E is B x M matrix of endmembers in reflectance
% X is B x N matrix of spectra    in reflectance
% dataW is B x N matrix of albedos of spectra in X
% mu is tradeoff between error and pairwise distance between endmembers
%
% AlbLUT is a structure containing variables used to map from albedo to
% reflectance
%
% OptParams are parameters for the Quadratic Program for P
%
% OUTPUTS
% P is M+1 x N Matrix of proportions wrt reflectance
% F is M   x N Matrix of proportions wrt albedo
%
% Error is the value of the objective function at the end
%
% RSS is the mean RSS at the end
%

fprintf('Calculating Proportions...\n');
D = size(X,1);
N = size(X,2);
M = size(E,2);


%TRANSFORM ENDMEMBERS TO SS ALBEDOS DOMAIN
W = lookupAlbedo3(E, AlbLUT);

%INITIALIZE NONLINEAR ENDMEMBER AS REFLECTANCE OF RANDOM MEAN OF SS Albedos
%OF REFLECTANCE ENDMEMBERS
InitialF = isempty(F);
if(InitialF)
    F            = rand(M, N);
    InvSum       = 1./sum(F); %Could generate from a Dirichlet later
    F            = bsxfun(@times, F,InvSum);
end

%%%%%%%%%%%%
%%%FOR DEBUGGING ONLY
% %%%%%%%%%%%%
%  foo = load('NonLinProps2');
%  keyboard
%  F(:, 5001:10000)=foo.NonLinProps2;
% F = foo.NonLinProps;
%%%%%%%%%%%%
%%%FOR DEBUGGING ONLY
%%%%%%%%%%%%

%NEED TO DECIDE HOW TO INITIALIZE.  
%THIS METHOD ASSUMES THERE IS SOME NONLINEARITY
NonLinEndMems = convertToReflectance2(W*F, AlbLUT);
%THIS METHOD ASSUMES THERE IS NOT NONLINEARITY but requires some extra work
%right now
%NonLinEndMems = zeros(D, N);

%ESTIMATE P ALLOWING NON-ZERO PROPORTION ON NON-LINEAR TERM
NonLinThresh    = 0.01;
P               = unmix_qpas_MacMicP(X, E, NonLinEndMems, OptParams);
P(P<0)          = 0; %SOMETIMES ONE GETS SMALL NEGATIVE NUMBERS

%FIND TERMS WITH SMALL NONLINEAR PROPORTION.  THEY ARE CONSIDERED LINEAR.
%THE REST ARE CONSIDERED TO HAVE SOME NONLINEARITY
LinTerms        = (find(P(M+1, :)< NonLinThresh));
LinNonlinTerms  = setdiff(1:N, LinTerms);

%SET THE SMALL NONLINEAR PROPORTIONS TO 0 AND RENORMALIZE (IT WOULD BE MORE
%CORRECT TO RE-RUN THE QUADRATIC PROGRAM ON THE LINEAR TERMS BUT THIS IS
%MUCH FASTER AND DOESN'T SEEM LIKE IT COULD BE MUCH DIFFERENT
P(M+1,LinTerms)            = 0;
NewDenom                   = sum(P);
P                          = bsxfun(@times, P, 1./NewDenom);
WghtErr                    = X-E*P(1:M, :);
WghtErr(:, LinNonlinTerms) = bsxfun(@times, WghtErr(:, LinNonlinTerms), 1./P(M+1, LinNonlinTerms));
NegErrs                    = WghtErr<0;
WghtErr(NegErrs)           = 0;
BigErrs                    = WghtErr>1;
WghtErr(BigErrs)           = 1;
WghtErrAlb                 = lookupAlbedo3(WghtErr, AlbLUT);
F(:, LinNonlinTerms)       = unmix_qpas_MacMicF(WghtErrAlb(:, LinNonlinTerms), W, OptParams);
F(F<0)                     = 0;

%CALCULATE CURRENT VALUE OF OBJECTIVE FUNCTION
RofF    = convertToReflectance2(W*F, AlbLUT);
Ep      = E*P(1:M, :);
MicTerm = bsxfun(@times, RofF, P(M+1, :));
Err     = norm(X - Ep - MicTerm, 'fro');
RSSSum  = Err*Err/N;
SumE    = sum(E, 2);
V       = sum(sum(E.*E, 2) - (1/M)*SumE.*SumE)/(M-1);
Error   = (1-mu)*(RSSSum) + mu*V ;

fprintf('Done calculating proportions and the RSSSum, V, and Objective Function Values are ...\n %f   %f   %f\n', RSSSum, V, Error);
end