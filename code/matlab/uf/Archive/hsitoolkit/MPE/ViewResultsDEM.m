 function ViewResultsDEM(P, F, E, ENL, pixelData, parameters, varargin);
%function [P, F, E, ENL, Error, exitReason] = MacMicUnmixDEM(pixelData, parameters, DegreesI, DegreesE);
%
%INPUT
%pixelData  - input hyperspectral pixel data row vectors are pixel spectra (N x D)
%M          - number of endmembers to find in data
%parameters - See MacMicUnmixParameters
%DegreesI	- Degree value to use in the BDRF, angle of incidence
%DegreesE   - Degree value to use in the BRDF, angle of emergence
%Size	    - Dimension of the HSI image. ([ rows, columns])
%
%OUTPUT
%P          - proportions of macroscopic mixture, colum vectors are endmember proportions for the given pixel
%F          - proportions of microscopic mixture, colum vectors are endmember proportions for the given pixel
%E          - extracted endmembers from data, columns are endmember spectra
%ENL        - extracted nonlinear endmembers from data, columns are endmember spectra
%Error     - RSMEreg error as in ICE
%extiReason - gives reason  for alg. termination
%figHandles - handle to all figures created by alg

%THE DEM PART ONLY works for finding the proportions right now; it does not
%find endmembers

exitReason = -1;

if(length(varargin) > 0)
    DegreesI = varargin{1};
else
    DegreesI = 70;
end

if (length(varargin) > 1)
	DegreesE = varargin{2};
else
	DegreesE = -DegreesI;
end

MASK = varargin{3};

%ASSIGN PARAMETERS TO VARIABLES WITH SHORTER NAMES
M              = parameters.M;
M_NL		   = parameters.M_NL;	
vcaE           = parameters.vcaEndmembers;
muReg          = parameters.mu;
startingEL     = parameters.startingEndmembersL;
startingENL    = parameters.startingEndmembersNL;
learningDivide = parameters.learningDivide;
PASS           = parameters.PASS;
VERBOSE        = parameters.VERBOSE;
VCA_ITER	   = parameters.VCA_ITER;

%TRANSPOSE DATA BECAUSE ORIGINALLY WRITTEN DIFFERENT THAN CURRENT
%CONVENTION
pixelData      = pixelData';
D              = size(pixelData,1);
N              = size(pixelData,2);

%CREATE ALBEDO & REFLECTANCE CONVERSION PARAMETERS AND STRUCTURE
angleEmergence     = DegreesE; %-Degrees;%0;
angleIncidence     = DegreesI;%0;
mu                 = cosd(angleEmergence);
mu0                = cosd(angleIncidence);
s                  = mu0+mu;
t                  = (4*s)/((1+2*mu0)*(1+2*mu));
almosta            = 4*mu0*mu*t;
almostb            = 2*s*t; %b without r divided by 2
convStruct.s       = s;
convStruct.t       = t;
convStruct.almosta = almosta;
convStruct.almostb = almostb;
convStruct.mu      = mu;
convStruct.mu0     = mu0;

%CREATE PARAMETERS FOR ICE
lambda = N*muReg/((M-1)*(1-muReg));
lambdaproduct = lambda*(eye(M) - (ones([M,1])*ones([M,1])')/M);
%lambdaproductAlb = N*parameters.muAlbedo/((M-1)*(1-parameters.muAlbedo))*(eye(M) - (ones([M,1])*ones([M,1])')/M);
endmemberIters = 20;

%CREATE CONSTRAINT MATRICES
OptParams.M            = M;
OptParams.N            = N;
OptParams.Aeq          = ones([1, M]);
OptParams.beq          = 1;
OptParams.lb           = zeros([M, 1]);
OptParams.ub           = ones([M,1]);
OptParams.AeqR         = ones([1, M+1]);
OptParams.beqR         = 1;
OptParams.lbR          = zeros([M+1, 1]);
OptParams.ubR          = ones([M+1,1]);
OptParams.ConstErrFlag = 0.01;   %off by 0.01% indicates error
OptParams.Im = eye(M);

		WENL = lookupAlbedo3(ENL, convStruct);

	        
			%CALCULATE ERROR OF LINEAR (REFLECTANCE) TERM
	    	RofF         = convertToReflectance2_noclip(WENL*F, convStruct);
   	    	MicTerm      = bsxfun(@times, RofF, P(M+1, :));
  	    	WghtErrRef   = pixelData - MicTerm;


			%CALCULATE TOTAL ERROR : ICE OBJECTIVE FUNCTION
    		SqrAppErr    = WghtErrRef - E*P(1:M,:);
    		SqrAppErr    = SqrAppErr.*SqrAppErr;
    		SSE          = sum(SqrAppErr);
    		NormErr      = sqrt(SSE);
    		RSSSum       = sum(SSE(:))/N;
    		SumE         = sum(E, 2);
    		V            = sum(sum(E.*E, 2) - (1/M)*SumE.*SumE)/(M-1);
			SumENL		 = sum(WENL, 2);
			V2 		 	 = sum(sum(WENL.*WENL, 2) - (1/M)*SumENL.*SumENL)/(M-1);
    		Error        = (1-muReg)*(RSSSum) + muReg*V + muReg*V2; % + parameters.muAlbedo*V2;
			if (parameters.VERBOSE)
    			fprintf('E-Iteration Number  %d and Err is %f and RSS is %f\n', j, Error, RSSSum);
			end

ERR_IMG = reshapeMask(MASK,SSE');
figure();
imagesc(ERR_IMG, [0 0.2]);
hold on;

if (length(varargin) > 3)
	OS = varargin{4};
	plot(OS.groundTruth.Targets_colIndices, OS.groundTruth.Targets_rowIndices, 'wx');
end
title(strcat('Reconstruction Error, AVG = ', num2str(RSSSum)));


RSSSum
Error


