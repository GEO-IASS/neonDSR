function [P, F, Error, RSSSum] = MacMicUpdatePropsDEM(E, ENL, X, dataW, parameters, AlbLUT, OptParams)
%function [P, F, Error, RSSSum] = MacMicUpdateProps(E, ENL,X, dataW, InitF, mu, AlbLUT, OptParams)
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
D          = size(X,1);
N          = size(X,2);
M          = size(E,2); %RIGHT NOW, M SHOULD BE THE SAME FOR LINEAR AND NONLINEAR
MaxIters   = OptParams.MaxPIters; %Make > 1 if InitPFirst
Err        = zeros(MaxIters, 1);
ErrorPrev  = 0;
Error	   = 1;
InitMeth   = parameters.InitMeth;
mu         = parameters.mu;
InitF      = InitMeth.InitF;


%THESE VARIABLES ARE USED TO NOT UPDATE PROPORTIONS THAT GIVE SMALL ERROR
%THIS IS ONLY IMPLEMENTED FOR P RIGHT NOW.
P          = zeros(M+1, N);
F          = zeros(M, N);
ErrMaskP   = ones(1, N);
ErrMaskF   = ones(1,N);
NoErrIndsP = [];
NoErrIndsF = [];
ERRTHRESH  = 0.01;


%TRANSFORM ENDMEMBERS TO SS ALBEDOS DOMAIN
W = lookupAlbedo3(ENL, AlbLUT);

%%%INITIALIZE PROPORTIONS
if( InitMeth.InitPFirst )
    %%% CHECK TO SEE IF INITIAL PROPORTIONS HAVE BEEN PASSED IN
    InitializeP = isempty(InitMeth.InitP);
    %%% IF PASSED IN, DO NOTHING.  OTHERWISE
    %%% INITIALIZE JUST LINEAR PART WITH <= CONSTRAINTS
    if(InitializeP)
        P      = unmix_qpas_LMM_LessOrEq(X, E, ErrMaskP, OptParams);
        NLP    = 1-sum(P);
        P      = vertcat(P, NLP);
        P(P<0) = 0; P(P>1) = 1;        
    elseif(parameters.EstimateEndmembers == 1)
		P 	   = InitMeth.InitP;
	end
else
    %%% CHECK TO SEE IF INITIAL ALBEDO PROPORTIONS HAVE BEEN PASSED IN
    InitializeF = isempty(InitMeth.InitF);
    %IF NOT, GENERATE SOME
    %THIS METHOD IMPLICITLY ASSUMES THERE IS SOME NONLINEARITY
    if(InitializeF)
        %Could generate from a Dirichlet later
        %COULD ALSO CHANGE THIS TO <= CONSTRAINTS
        F = unmix_qpas_MacMicF(dataW, W, OptParams, ErrMaskF);
	end
    RofF = convertToReflectance2(W*F, AlbLUT);
end

%RETURN THE BEST RESULT OVER ALL ITERATIONS
Best.Error = 1e10;
Best.P = [];
Best.F = [];
Best.RSSSum = 0;

for IterNum = 1:MaxIters
    %ESTIMATE P ALLOWING NON-ZERO PROPORTION ON NON-LINEAR TERM
    if((IterNum == 1) & (InitMeth.InitPFirst))
        %IF WE INITIALIZE P FIRST, THEN WE DON'T UPDATE IT THE FIRST TIME
        %THROUGH THE LOOP
		if (parameters.VERBOSE)
        	fprintf('Skipping updating P the first time through the loop.\n');
		end
    else
        oldP            = P;
        P               = unmix_qpas_MacMicP(X, E, RofF, OptParams, ErrMaskP);
        P(P<0)          = 0; %SOMETIMES ONE GETS SMALL NEGATIVE NUMBERS
        P(:,NoErrIndsP) = oldP(:, NoErrIndsP);
    end
    
    %FIND TERMS WITH SMALL NONLINEAR PROPORTION.  THEY ARE CONSIDERED LINEAR.
    %THE REST ARE CONSIDERED TO HAVE SOME NONLINEARITY
    NonLinThresh    = 0.01;
    LinTerms        = (find(P(M+1, :)< NonLinThresh));
    LinNonlinTerms  = setdiff(1:N, LinTerms);
    
    %SET THE SMALL NONLINEAR PROPORTIONS TO 0 AND RENORMALIZE (IT WOULD BE MORE
    %CORRECT TO RE-RUN THE QUADRATIC PROGRAM ON THE LINEAR TERMS BUT THIS IS
    %MUCH FASTER AND DOESN'T SEEM LIKE IT COULD BE MUCH DIFFERENT
    P(M+1,LinTerms)            = 0;
    NewDenom                   = sum(P);
    P                          = bsxfun(@times, P, 1./NewDenom);
    if(~isempty(LinNonlinTerms))
        WghtErr                    = X-E*P(1:M, :);
        WghtErr(:, LinNonlinTerms) = bsxfun(@times, WghtErr(:, LinNonlinTerms), 1./P(M+1, LinNonlinTerms));
        WghtErr(WghtErr<0)         = 0;
        WghtErr(WghtErr>1)         = 1;
        WghtErrAlb                 = lookupAlbedo3(WghtErr, AlbLUT);
        oldF                       = F;
        F(:, LinNonlinTerms)       = unmix_qpas_MacMicF(WghtErrAlb(:, LinNonlinTerms), W, OptParams, ErrMaskF);
        F(F<0)                     = 0;
    end
    
    %CALCULATE CURRENT VALUE OF OBJECTIVE FUNCTION
    RofF         = convertToReflectance2(W*F, AlbLUT);
    Ep           = E*P(1:M, :);
    MicTerm      = bsxfun(@times, RofF, P(M+1, :));
    SqrAppErr    = X - Ep - MicTerm;
    SqrAppErr    = SqrAppErr.*SqrAppErr;
    SSE          = sum(SqrAppErr);
    NormErr      = sqrt(SSE);
    Err(IterNum) = sum(NormErr);
    RSSSum       = sum(SSE(:))/N;
    SumE         = sum(E, 2);
    V            = sum(sum(E.*E, 2) - (1/M)*SumE.*SumE)/(M-1);
	ErrorPrev 	 = Error;
	SumENL		 = sum(W, 2);
	V2 		 	 = sum(sum(W.*W, 2) - (1/M)*SumENL.*SumENL)/(M-1);
    Error        = (1-mu)*(RSSSum) + mu*V;
	if (OptParams.useFullObjectiveFunc == 1)
		Error = Error + mu*V2; % + parameters.muAlbedo*V2;
	end
	if (parameters.VERBOSE)
    	fprintf('P-Iteration Number  %d and Err is %f and RSS is %f\n', IterNum, Error, RSSSum);
	end
    
    ErrMaskP     = NormErr > ERRTHRESH;
    NoErrIndsP   = find(1-ErrMaskP);

	if (Error <= Best.Error)
		Best.Error = Error;
		Best.P = P;
		Best.F = F;
		Best.RSSSum = RSSSum;
	end

	%QUIT IF CONVERGED (IF ESTIMATING ENDMEMBERS OUTSIDE OF THIS FUNCTION)
	if (parameters.EstimateEndmembers == 1 && abs(ErrorPrev - Error) < 1e-7 && IterNum > 5)
		break;
	end

end %for IterNum

P = Best.P;
F = Best.F;
Error = Best.Error;
RSSSum = Best.RSSSum;


if (parameters.VERBOSE)
	fprintf('Done calculating proportions and the RSSSum, V, and Objective Function Values are ...\n %f   %f   %f\n', RSSSum, V, Error);
end
end
