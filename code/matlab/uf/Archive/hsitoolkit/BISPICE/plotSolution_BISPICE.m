function E = plotSolution_BISPICE(SolutionStruct, HylidImageStruct, GroundSpectra, Filename)
% plotSolution_BISPICE(SolutionStruct, HylidImageStruct, GroundSpectra, Filename)
%
% Produces useful visualizations including PCA, Proportion Maps, and automatically labels
% Endmembers by closest GroundSpectra.
%
% INPUT
%
%	SolutionStruct - The output of BISPICE_Train
% 	HylidImageStruct - The output of the Subimage Selector
%			   Used fields are Data, info.wavelength, groundTruth, RGB
% 	GroundSpectra - An Mx1 array of structures with fields
%			label (text), wavelength (Dx1), Data (NxD)
%			Set to [] if no GroundSpectra is Available.
% 	Filename - Filename to save figures. Set to '' to disable.
%		     Figures are saved to ./figs/* and ./pngs/*
%		     Data is saved to ./data/*
%
% EXAMPLE
%
% 	SS = BISPICE_Train( HSI.Data, BISPICE_Parameters());
% 	plotSolution_BISPICE( SS, HSI, [], '');
%
Data = HylidImageStruct.Data;
if (size(Data,3) ~= 1)
    Data = reshape(Data, [size(Data,1)*size(Data,2), size(Data,3)])';
end
Targets = [HylidImageStruct.groundTruth.Targets_colIndices ;...
    HylidImageStruct.groundTruth.Targets_rowIndices];
SS = SolutionStruct;
XLabel = HylidImageStruct.info.wavelength;
Mask = [];
FRGB = HylidImageStruct.RGB;
GS = GroundSpectra;
GS_Scale = 1.0;
close all;
if (length(SS.pruned) < size(SS.endmembers,2))
    SS.pruned = logical(zeros(1, size(SS.endmebers,2)));
end
SS.theta = SS.extra.theta;
SS.beta = SS.extra.beta;
SS.alpha = SS.extra.alpha;
SS.gammaMatrix = SS.extra.gammaMatrix;
SS.initial_endmembers = SS.extra.initial_endmembers;
SS.initial_props = SS.extra.initial_props;

if (length(Mask) <= 1)
    Mask = logical(ones([size(Data,2), 1]));
else
    figure();
    imagesc(reshape(Mask, [size(FRGB,1) size(FRGB,2)]));
    hold on; title('Mask');
end
SS.gamma = SS.beta;

if (length(Filename) > 1) save(strcat('./data/', Filename,'_Data.mat'), 'SS'); end;
FRGB2 = reshape(FRGB, [size(FRGB,1)*size(FRGB,2) size(FRGB,3)]);
ERR = zeros(size(FRGB2,1) , 1);
ERR_LINEAR = ERR;
Impact_MAP = zeros(size(ERR));
j = 1;
for i=1:size(FRGB2,1)
    if (~Mask(i)) continue; end;
    
    FullTerm = [SS.endmembers, SS.endmembers_cross] * SS.theta{i}; %gene_gamma(SS.endmembers, SS.theta{i});
    if (length(Data) > 1)
        ERR(i) = norm(Data(:,i) - FullTerm)^2;
        if (length(SS.initial_props) > 1)
            ERR_LINEAR(i) =  norm(Data(:,i) - SS.initial_endmembers * SS.initial_props(i,:)')^2;
        end
    end
    
    BilinearTerm = FullTerm - SS.endmembers * SS.alpha{i};
    Impact = norm(BilinearTerm)/norm(FullTerm);
    
    if (Impact >= 0.5)
        FRGB2(i,:) = 1.0 * ones(size(FRGB2,2), 1);
    end
    Impact_MAP(i) = Impact;
    j = j+1;
end

if (length(Data) > 1)
    figure();
    imagesc(reshape(ERR, [size(FRGB,1) size(FRGB,2)]), [0 0.2]); hold on;
    title(strcat('Squared Error of Bilinear Model Clipped at 0.2 : AVG ERR = ', num2str(sum(ERR)/sum(Mask))));
    if (length(Targets) > 1)plot(Targets(1,:), Targets(2,:), 'wx'); hold on;end
    outputFig(strcat(Filename,'_ReconstructionError'));
    
    if (length(SS.initial_props) > 1)
        figure();
        imagesc(reshape(ERR_LINEAR, [size(FRGB,1) size(FRGB,2)]), [0 0.2]); hold on;
        title(strcat('Squared Error of Initialization at 0.2 : AVG ERR = ', num2str(sum(ERR_LINEAR)/sum(Mask))));
        if (length(Targets) > 1)plot(Targets(1,:), Targets(2,:), 'wx'); hold on;end
        if (sum(SS.pruned) == 0)
            %outputFig(strcat(Filename,'_ReconstructionError_LinearModel'));
        end
    end
end



figure();
imagesc(reshape(FRGB2, size(FRGB))); hold on;
title('Locations where the Bilinear Term contributes >50%');
if (length(Targets) > 1)plot(Targets(1,:), Targets(2,:), 'rx'); hold on;end
outputFig( strcat(Filename,'_BilinearAreas'));

figure();
imagesc(reshape(Impact_MAP, [size(FRGB,1) size(FRGB,2)])); hold on;
title('Ratio of the Norm of the Bilinear Term to the Norm of the Full Term');
if (length(Targets) > 1)
    plot(Targets(1,:), Targets(2,:), 'wx');
end

outputFig( strcat(Filename,'_BilinearTermStrength'));

%	figure();
%	plot(XLabel, SS.endmembers);
%	title('Endmembers');
%	outputFig( strcat(Filename,'_Endmembers'));


N = size(FRGB2,1);
[D R] = size(SS.endmembers);


figure();
GAMMA = zeros(N,1);
for j=1:N
    GAMMA(j) = max(SS.gamma{j});
end
imagesc(reshape(GAMMA, [size(FRGB,1) size(FRGB,2)]));
hold on;
title(strcat('Maxmum Gamma'));
if (length(Targets) > 1)
    plot(Targets(1,:), Targets(2,:), 'wx');
end
outputFig( strcat(Filename,'_MaxGamma'));

%outputFig( strcat(Filename,'_MaxGammaAlpha'));
%endmember fig



MSE_M = zeros(R,1);
MAP = zeros(R,1);
MPlus = SS.initial_endmembers;
SolutionStruct = SS;
USEDj = zeros(R,1);
USEDi = zeros(R,1);
COL = ['r', 'g', 'b', 'c', 'm','y', 'k', 'w'];
COL2 =  ['ro'; 'go'; 'bo'; 'co'; 'mo';'yo'; 'ko'; 'r*'; 'g*'; 'b*';'c*'; 'm*'; 'y*'; 'k*'];
if (size(SS.initial_endmembers,2) == R)

for k=1:R
	MIN = 1e10;
	BEST = -1;
	BEST2 = -1;
 for i=1:R
	if (USEDi(i) == 1) continue; end;
	for j=1:size(MPlus,2)
		if (USEDj(j) == 1) continue; end;
		TMP = norm(MPlus(:,j) - SS.endmembers(:,i))^2;
		if (TMP < MIN) MIN = TMP; BEST = j; BEST2 = i; end;
	end
	
 end
	MSE_M(BEST2) = MIN;
	MAP(BEST2) = BEST;
	USEDj(BEST) = 1;
	USEDi(BEST2) = 1;
end
MAP


figure(); 

for i=1:R
	if (SS.pruned(i)) continue; end;
	plot(XLabel, SolutionStruct.endmembers(:,i), strcat('-', COL(i))); hold on;
	plot(XLabel, MPlus(:,MAP(i)), strcat('--', COL(i))); hold on;
end
set(gca, 'XLim', [min(XLabel) max(XLabel)]);

%set(gca, 'XLim', [0.4 2.5]);
title('Endmembers');
xlabel('Wavelength');
	outputFig( strcat(Filename,'_Endmembers'));
end

	LABELS = cell([R,1]);
	for i = 1:R
		LABELS{i} = strcat('Endmember ', num2str(i));
	end


if (length(GS) > 1)
 kernels = {@MAHALANOBIS @SAM @L2_NORM};
 file_string = {'_MAH', '_SAM' , ''};
 title_string = {' Mahalanobis in each Band', ' Spectral Angle', ' L2 Norm'};
 for i=1:D
	kernel_params.var(i) = var( Data(i,:));
 end
PRUNED_WV = cell(1, sum(SS.pruned(1:R)));
PRUNED_EM = cell(1, sum(SS.pruned(1:R)));

 for z=2:length(kernels)
	kernel = kernels{z};
	HANDLES = zeros([R,1]);
	figure();

	COL = ['r', 'g', 'b', 'c', 'm','y', 'k'];
	WTMP = round(XLabel);
	WBOOL = zeros( 2000, 1);
	for i=1:length(WTMP)
		WBOOL(WTMP(i)) = 1;
	end
	WBOOL = logical(WBOOL);
	i3 = 0;
	for i=1:R
		if (~SS.pruned(i)) i3 = i3+1; end;
		BestIndex = 1;
		Best = zeros(size(GS(1).wavelength)) + 0.0001;
		BestVal = kernel(SolutionStruct.endmembers(:,i), Best(1:D), kernel_params);
		BestLabel = 'Shadow';
		BestWave = GS(1).wavelength;
		for j=1:length(GS)
			WL = WBOOL(GS(j).wavelength) ;
			
			for k=1:size(GS(j).Data,1)
				TMP = kernel(GS(j).Data(k,WL)' ./ GS_Scale , SolutionStruct.endmembers(:,i), kernel_params);
				if (TMP < BestVal)
					BestVal = TMP;
					BestIndex = j;
					BestLabel = GS(j).label;
					if (length(GS_Scale) <= 1)
						Best = GS(j).Data(k,:) ./ GS_Scale;
						BestWave = GS(BestIndex).wavelength;
					else 
						Best = GS(j).Data(k,WL) ./ GS_Scale';
						BestWave = XLabel;
					end


				end
			end
		end


		%LABELS{2*i-1} = strcat('Endmember ', num2str(i));
		
		LABELS{i} = BestLabel;
		if (SS.pruned(i))
			HANDLES(i) = 0;
			if (z == length(kernels))
				PRUNED_WV{i-i3} = GS(BestIndex).wavelength;
				PRUNED_EM{i-i3} = Best';
			end
		else
			%HANDLES(i) = plot(GS(BestIndex).wavelength, Best, strcat('--', COL(i3))); hold on;
			HANDLES(i) = plot(BestWave, Best, strcat('--', COL(i3))); hold on;
			plot(XLabel, SolutionStruct.endmembers(:,i), strcat('-', COL(i3))); hold on;
			%set(gca, 'XLim', [min(XLabel), max(Xlabel)]);
		end
		if (z == 2) disp(strcat('BestVal for ',LABELS{i}, ' is ', num2str( BestVal))); end;
	end
	legend(HANDLES(HANDLES ~= 0), LABELS{HANDLES ~= 0}, 'Location' , 'NorthWest');
	set(gca, 'XLim', [min(XLabel), max(XLabel)]);
	title(strcat('Endmembers and Closest Ground Spectra', title_string{z}));
	xlabel('Wavelength');

	outputFig(strcat(Filename, '_EMembers_WithGroundSpectra', file_string{z}));
	
	figure(); 
	R2 = R - sum(SS.pruned(1:R));
	if (R2 < 7)
		COLS = 3;
	else
		COLS = 4;	
	end
	ROWS = ceil(R2/COLS);
	hold on; h = title(strcat('Proportions Automatically Labelled by', title_string{z}));

	i2 = 1
	for i=1:R
		if (SS.pruned(i)) continue; end;

		subplot(ROWS , COLS ,i2);
		i2 = i2+1;
		ALPHA = zeros(N,1);
		for j=1:N
			ALPHA(j) = SS.alpha{j}(i);
		end
		imagesc(reshape(ALPHA, [size(FRGB,1) size(FRGB,2)]), [0 1.0]);
		hold on;
		%title(strcat('Proportion #', num2str(i)));
		title(LABELS{i});
	end
	suplabel(strcat('Proportions Automatically Labelled by', title_string{z}),'t', [0.08 0.08 0.86 0.86])
	outputFig( strcat(Filename,'_Proportions', file_string{z}));

%Bilinear Proportions
	figure();
	R2 = R*(R-1)/2 - sum(SS.pruned(R+1:end));
	if (R2< 3)
		COLS = 2;
	elseif (R2 < 7)
		COLS = 3;
	else
		COLS = 4;	
	end
	ROWS = ceil(R2/COLS);

	hold on; title('Proportions');
	i3 = 0;
	iplot = 1;
	for i=1:(R-1)
	 for i2=(i+1):R
		i3 = i3+1;
		if (SS.pruned(i3+R)) continue; end;
		
		subplot(ROWS , COLS ,iplot);
		iplot = iplot+1;
		ALPHA = zeros(N,1);
		for j=1:N
			ALPHA(j) = SS.theta{j}(i3+R);
		end
		imagesc(reshape(ALPHA, [size(FRGB,1) size(FRGB,2)]), [0 1.0]);
		%set(gca, 'XLim', [1 156]);
		%set(gca, 'YLim', [1 61]);
		hold on;
		%title(strcat('Proportion #', num2str(i)));
		if (SS.pruned(i3+R))
			title(strcat('Pruned'));
		else
			title(strcat(LABELS{i},'/',LABELS{i2}));
		end
		%figure();
	 end
	end
	%suplabel(strcat('Bilinear Proportions Automatically Labelled by ',title_string{z}),'t', [0.08 0.08 0.86 0.86]);
	outputFig( strcat(Filename,'_BilinearProportions', file_string{z}));


 end
size(PRUNED_WV)
size(PRUNED_EM)

 if (length(PRUNED_WV) > 0)
	HANDLES5 = zeros(1, size(PRUNED_WV,2));
	i3 = 1;
	figure();
	for i=1:R
		if (~SS.pruned(i)) continue; end;
		HANDLES5(i3) = plot(PRUNED_WV{i3}, PRUNED_EM{i3}, strcat('--', COL(i3))); hold on;
		plot(XLabel, SolutionStruct.endmembers(:,i), strcat('-', COL(i3))); hold on;
		i3 = i3+1;		
	end
	legend(HANDLES5(1:end), LABELS{HANDLES == 0}, 'Location' , 'NorthWest');
	set(gca, 'XLim', [min(XLabel), max(XLabel)]);
	title(strcat('Pruned Endmembers and Closest Ground Spectra', title_string{z}));
	xlabel('Wavelength');

	outputFig(strcat(Filename, '_EMembers_PrunedOnly'));

 end

else

%Proportions
	figure(); 
	R2 = R - sum(SS.pruned(1:R));
	if (R2 < 7)
		ROWS = ceil(R2/2);
		COLS = 2;
	else
		ROWS = ceil(R2/3);
		COLS = 3;
	end
	%hold on; h = title(strcat('Proportions Automatically Labelled by', title_string{z}));

	hold on; title('Proportions');

	i2 = 1
	for i=1:R
		if (SS.pruned(i)) continue; end;

		subplot(ROWS , COLS ,i2);
		i2 = i2+1;
		ALPHA = zeros(N,1);
		for j=1:N
			ALPHA(j) = SS.alpha{j}(i);
		end
		imagesc(reshape(ALPHA, [size(FRGB,1) size(FRGB,2)]), [0 1.0]);
		hold on;
		%title(strcat('Proportion #', num2str(i)));
		title(LABELS{i});
	end
	outputFig( strcat(Filename,'_Proportions'));

%Bilinear Proportions
	figure();
	R2 = R*(R-1)/2 - sum(SS.pruned(R+1:end));
	if (R2 < 7)
		ROWS = ceil(R2/2);
		COLS = 2;
	else
		ROWS = ceil(R2/3);
		COLS = 3;
	end

	hold on; title('Proportions');
	i3 = 0;
	iplot = 1;
	for i=1:(R-1)
	 for i2=(i+1):R
		i3 = i3+1;
		if (SS.pruned(i3+R)) continue; end;
		
		subplot(ROWS , COLS ,iplot);
		iplot = iplot+1;
		ALPHA = zeros(N,1);
		for j=1:N
			ALPHA(j) = SS.gammaMatrix{j}(i,i2);
		end
		imagesc(reshape(ALPHA, [size(FRGB,1) size(FRGB,2)]), [0 1.0]);
		hold on;
		%title(strcat('Proportion #', num2str(i)));
		if (SS.pruned(i3+R))
			title(strcat('Pruned'));
		else
			title(strcat(LABELS{i},'/',LABELS{i2}));
		end

	 end
	end
	suplabel(strcat('Bilinear Proportions Automatically Labelled by L2 Norm',''),'t', [0.08 0.08 0.86 0.86]);
	outputFig( strcat(Filename,'_BilinearProportions'));

	figure();
	plot(XLabel, SS.endmembers); hold on;
	set(gca, 'XLim', [min(XLabel), max(XLabel)]);
	title('Endmembers');
	outputFig( strcat(Filename,'_Endmembers'));
end






%ASTER_4 = [ SolutionStruct.endmembers, Data(:, Mask)];
%[COEFF SCORE_3] = princomp(ASTER_4');
%figure(); I=(1:R); plot3(SCORE_3(I,1) , SCORE_3(I,2), SCORE_3(I,3), 'ro'); hold on;
%I=(4:6); plot3(SCORE_3(I,1) , SCORE_3(I,2), SCORE_3(I,3), 'go'); hold on;
%I=((R+1):size(ASTER_4,2)); plot3(SCORE_3(I,1) , SCORE_3(I,2), SCORE_3(I,3), 'bx'); hold on;
%title('3D PCA');
%	outputFig( strcat(Filename,'_3DPCA'));



ASTER_4 = [ SolutionStruct.endmembers(:,~SS.pruned(1:R))];
i3 = 0;
F1 = size(ASTER_4,2);
for i=1:R
	for j=(i+1):R
		i3 = i3+1;
		if (SS.pruned(i3)) continue; end;	
		PROD = SolutionStruct.endmembers(:,i) .* SolutionStruct.endmembers(:,j);
		ASTER_4 = [ASTER_4, PROD];
	end
end
F2 = size(ASTER_4,2);
ASTER_4 = [ASTER_4 , Data(:, Mask)];
[COEFF SCORE_3] = princomp(ASTER_4');
figure(); I=(1:F1); plot3(SCORE_3(I,1) , SCORE_3(I,2), SCORE_3(I,3), 'ro'); hold on;
I=(F1+1:F2); plot3(SCORE_3(I,1) , SCORE_3(I,2), SCORE_3(I,3), 'go'); hold on;
I=(F2+1:size(ASTER_4,2)); plot3(SCORE_3(I,1) , SCORE_3(I,2), SCORE_3(I,3), 'bx'); hold on;
title('3D PCA');
	outputFig( strcat(Filename,'_3DPCA_WithProducts'));




figure();
ASTER_4 = [Data(:, Mask)];
[COEFF SCORE_3] = princomp(ASTER_4');
FULL_IND = zeros(1,size(ASTER_4,2));
j=0;
for i=1:N
	[MX MI] = max(SolutionStruct.theta{i});
	if (MX == 0) continue; end;
	j = j+1;
	FULL_IND(j) = MI;
end

HANDLES2 = zeros((R+1),1);
i2 = 0;
for i=1:R
	I = (FULL_IND == i);

	if (SS.pruned(i))
		HANDLES2(i) = 0;
	else
		i2 = i2+1;
		HANDLES2(i) = plot3(SCORE_3(I,1) , SCORE_3(I,2), SCORE_3(I,3), strcat(COL(i2), 'x')); hold on;
	end

end
%for i=(R+1):(R + R*(R-1)/2)
	I = (FULL_IND > R);
	HANDLES2(R+1) = plot3(SCORE_3(I,1) , SCORE_3(I,2), SCORE_3(I,3), strcat('kx')); hold on;
%end
	LABELS{R+1} = 'Bilinear';
	legend(HANDLES2(HANDLES2 ~= 0), LABELS{HANDLES2 ~= 0}, 'Location' , 'NorthWest');
	title('3D PCA Colored by Highest Proportion');
%	outputFig( strcat(Filename,'_3DPCA_Colors'));

%end


figure();
HANDLES3 = [];
i2 = 0;
for i=1:R
	I = (FULL_IND == i);
	if (SS.pruned(i))
		HANDLES3 = [HANDLES3; 0];
	else
		i2 = i2+1;
		HANDLES3 = [HANDLES3 ; plot3(SCORE_3(I,1) , SCORE_3(I,2), SCORE_3(I,3), strcat(COL(i2), 'x'))]; hold on;
	end
end
i1 = 1;
i2 = 1;
i3 = R;
for i=(R+1):(R + R*(R-1)/2)
	I = (FULL_IND == i);
	i2 = i2+1;
	if (i2 > R) i1=i1+1; i2=i1+1;end;

	if (sum(I) == 0) continue; end;
	i3 = i3+1;
	HANDLES3 = [HANDLES3 ; plot3(SCORE_3(I,1) , SCORE_3(I,2), SCORE_3(I,3), COL2(length(COL2)-(i3-R-1),:))]; hold on;
	LABELS{i3} = strcat(LABELS{i1},'/',LABELS{i2});
end
	legend(HANDLES3(HANDLES3 ~= 0), LABELS{HANDLES3 ~= 0}, 'Location' , 'NorthEast');
	title('3D PCA Colored by Highest Proportion Including Bilinear Terms');
	%outputFig( strcat(Filename,'_3DPCA_BilinearColors'));

end




function outputFig(f)
	if (f(1) ~= '_' )
		hgsave(gcf, strcat('./figs/', f,'.fig'));
		print(gcf, '-dpng', strcat('./pngs/',f));
	end
end

%Measures for Ground Spectra
function alpha = SAM(X,Y,P)
	X = X / norm(X);
	Y = Y / norm(Y);
	alpha = acos( X'*Y );
end

function alpha = L2_NORM(X,Y,P)
	alpha = norm(X-Y);
end

function alpha = MAHALANOBIS(X,Y,P)
	alpha = 0;
	for i=1:length(X)
		alpha = alpha + (X(i) - Y(i))^2 / P.var(i);
	end
end

function alpha = HYBRID(X,Y,P)
	alpha = 0.5 * L2_NORM(X,Y,P) + 0.5 * SAM(X,Y,P);
end
