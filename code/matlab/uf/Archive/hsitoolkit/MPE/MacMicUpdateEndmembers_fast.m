 function [E, ENL, WENL, Error] = MacMicUpdateEndmembers(pixelData, E, WENL, F, P, parameters, convStruct);
%function [E, ENL, WENL, Error] = MacMicUpdateEndmembers(pixelData, E, WENL, F, P, parameters, convStruct);
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


D              = size(pixelData,1);
N              = size(pixelData,2);
M              = parameters.M;
M_NL		   = parameters.M;	
muReg          = parameters.mu;
Error		   = 1e10;

%CREATE PARAMETERS FOR ICE
lambda			 = N*muReg/((M-1)*(1-muReg));
ssd_product		 = (eye(M) - (ones([M,1])*ones([M,1])')/M);
lambdaproduct	 = lambda*ssd_product;
%lambdaproductAlb = N*parameters.muAlbedo/((M-1)*(1-parameters.muAlbedo))*(eye(M) - (ones([M,1])*ones([M,1])')/M);
endmemberIters = 20;

		%FIND TERMS WITH SMALL NONLINEAR PROPORTION.  THEY ARE CONSIDERED LINEAR.
   		%THE REST ARE CONSIDERED TO HAVE SOME NONLINEARITY
		NonLinThresh    = 0.05;
		LinTerms        = (find(P(M+1, :)< NonLinThresh));
		LinNonlinTerms  = setdiff(1:N, LinTerms);

		disp('Calculating Endmembers...');
		%USE THE BEST ENDMEMBERS OVER ALL ITERATIONS
		BestE.Error = 1e10;
		BestE.E = [];
		BestE.W = [];

		for z=1:endmemberIters
	       	  
			%-- APPLY Gradient Descent TO GET THE (NONLINEAR) ALBEDO ENDMEMBERS

	        derFunc     = zeros(1,N);	
    	    sliceP      = P(M+1,:);
    	    largeSliceP = P(1:M,:);		
			parfor j=1:D
				WF				 = WENL(j,:)*F;
				derRefFunct 	 = slopeOfReflectanceCurve2(WF, convStruct);

    	        TMP			     = (sliceP.*derRefFunct)';
				derFunc			 = F* (TMP'.*(pixelData(j,:) - E(j,:)*largeSliceP - sliceP.*convertToReflectance2(WF, convStruct)))';
				derFunc			 = (-2).*(1-muReg).*derFunc./N + 2*muReg*ssd_product * WENL(j,:)' ./ (M-1);
				WENL(j,:)		 = WENL(j,:) - derFunc';
				
			end	
			%}
			
			%-- END OF NONLINEAR UPDATE --
			

			%-- APPLY ICE UPDATE TO GET THE (LINEAR) ENDMEMBERS --

	    	RofF         = convertToReflectance2_noclip(WENL*F, convStruct);
   	    	MicTerm      = bsxfun(@times, RofF, P(M+1, :));
  	    	WghtErrRef   = pixelData - MicTerm;

			LP = P(1:M,:)';
    		E = ((LP'*LP + lambdaproduct)\(LP'*WghtErrRef'))';

			%-- END OF LINEAR UPDATE --

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
			ErrorEPrev	 = Error;
    		Error        = (1-muReg)*(RSSSum) + muReg*V + muReg*V2; % + parameters.muAlbedo*V2;
			if (parameters.VERBOSE)
    			fprintf('E-Iteration Number  %d and Err is %f and RSS is %f\n', z, Error, RSSSum);
			end

			% SET BEST RESULT
			if (Error < BestE.Error)
				BestE.Error = Error;
				BestE.E = E;
				BestE.W = WENL;
			end

			%BREAK IF CONVERGED
			if (abs(ErrorEPrev - Error) < 1e-7)
				%break;
			end
		end

		WENL = BestE.W;
		E = BestE.E;
		Error = BestE.Error;
		ENL = convertToReflectance2_noclip(WENL, convStruct);
