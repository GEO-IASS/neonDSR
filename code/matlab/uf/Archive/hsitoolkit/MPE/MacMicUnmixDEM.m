 function [P, F, E, ENL, Error, exitReason] = MacMicUnmixDEGD(pixelData, parameters, varargin);
%function [P, F, E, ENL, Error, exitReason] = MacMicUnmixDEGD(pixelData, parameters, DegreesI, DegreesE);
%
%INPUT
%pixelData  - input hyperspectral pixel data row vectors are pixel spectra (N x D)
%M          - number of endmembers to find in data
%parameters - See MacMicUnmixParameters
%DegreesI	- Degree value to use in the BDRF, angle of incidence
%DegreesE   - Degree value to use in the BRDF, angle of emergence
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

%ASSIGN PARAMETERS TO VARIABLES WITH SHORTER NAMES
M              = parameters.M;
M_NL		   = parameters.M; %TODO : Separate linear and nonlinear M	
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
OptParams.MaxPIters	   = 20;


fprintf('Looking up Albedo 3...\n');
tic
dataW = lookupAlbedo3(pixelData, convStruct);
toc
fprintf('Done Looking up Albedo 3...\n');

if (vcaE ~= 1)
	VCA_ITER = 1;
else
	fprintf('Initializing with %d iterations of VCA...\n',VCA_ITER);
end

%RUN VCA AND PROPORTION ESTIMATION SEVERAL TIMES AND TAKE THE BEST RESULT (INITIALIZATION STEP)
BestVCA.Error = 1e10;
BestVCA.P = [];
BestVCA.F = [];

for j=1:VCA_ITER

	%GET ENDMEMBERS
	if vcaE == 1
    	fprintf('Running VCA on Reflectance...\n');
    	tic
    	[E ~, ~] = VCA( pixelData, 'Endmembers', M);
    	toc
    	fprintf('Done Running VCA...\n');
        	fprintf('Running VCA on Albedo...\n');
    	tic
    	[WENL ~, ~] = VCA( dataW, 'Endmembers', M_NL);
    	toc
    	fprintf('Done Running VCA...\n');
    	ENL = convertToReflectance2(WENL, convStruct);

		%
		OptParams.MaxPIters	   = 5;
	else
    	E   = double(startingEL);
    	ENL = double(startingENL);
	end

	%Testing InitP First
	%
	%if (mod(j,2) == 1)
	%	parameters.InitMeth.InitPFirst = 1;
	%else
	%	parameters.InitMeth.InitPFirst = 0;
	%end

	%GET PROPORTIONS
	tic
	OptParams.useFullObjectiveFunc = 0;
	[P, F, Error, RSSsum] = MacMicUpdatePropsDEM(E, ENL, pixelData, dataW, parameters, convStruct, OptParams);
	toc

	if (Error < BestVCA.Error)
		BestVCA.Error = Error;
		BestVCA.P = P;
		BestVCA.F = F;
	end
end
F = BestVCA.F;
P = BestVCA.P;
Error = BestVCA.Error;
OptParams.useFullObjectiveFunc = 1;

if(isempty(parameters.wavelengths))
    figure(1234);plot(E);   title('Initial Linear Endmembers');   drawnow
    figure(1248);plot(ENL); title('Initial Nonlinear Endmembers');drawnow
else
    figure(1234);plot(parameters.wavelengths, E);   title('Initial Linear Endmembers');   drawnow
    figure(1248);plot(parameters.wavelengths, ENL); title('Initial Nonlinear Endmembers');drawnow
end

%ITERATIVELY TRAIN THE MODEL USING ALTERNATING OPTIMIZATION
if (parameters.EstimateEndmembers == 1)
    exitReason    = 1;
    maxIterations = 120;
	OptParams.MaxPIters	   = 20;
 
    for countIter = 1:maxIterations
        prevError = Error;
    	fprintf('Global Iteration Number %d and Err is %f\n', countIter, Error);
        
		%SOLVE FOR THE ENDMEMBERS
		[E ENL WENL Error] = MacMicUpdateEndmembers_fast(pixelData, E, WENL, F, P, parameters, convStruct);

		%DISPLAY ENDMEMBER EVOLUTION
		if (parameters.VERBOSE)
			figure(444);
			plot(parameters.wavelengths, E); hold on; title('Linear Endmembers');
			figure(555);
			plot(parameters.wavelengths, ENL); hold on; title('Nonlinear Endmembers');
		end

		%RESET THE PROPORTIONS SOMETIMES, BUT USE THE OLD P MOST OF THE TIME
		if (Error < prevError && countIter > 10 && mod(countIter,5) ~= 0)
			parameters.InitMeth.InitP = P;
			parameters.InitMeth.InitPFirst = 1;
		end

		%SOLVE FOR THE PROPORTIONS
		[P, F, Error, RSSsum] = MacMicUpdatePropsDEM(E, ENL, pixelData, dataW, parameters, convStruct, OptParams);


		%BREAK IF CONVERGED OR ERROR GOING UP
        if prevError - Error < 1e-7 && countIter > 20
            exitReason = 3;
            break;
        end
    end
end
Error=RSSsum;

end
