function [P, F, endmembers, Error, exitReason, figHandles] = C4MModel( pixelData, M, vcaEndmembers, mu, startingEndmembers, learningDivide)
figHandles=[];
exitReason = -1;
%input
%pixelData - input hyperspectral pixel data column vectors are pixel spectra (DxN)
%M - number of endmembers to find in data
%vcaEndmember - flag to use VCA to find endmembers or self extract
%   1 = use VCA
%   0 = not use VCA
%mu - same as ICE mu
%startingEndmembers - inital points to use as endmembers
%update for learning rate parameter

%output
%P - proportions of macroscopic mixture, colum vectors are endmember proportions for the given pixel
%F - proportions of microscopic mixture, colum vectors are endmember
%proportions for the given pixel
%endmember - extracted endmembers from data, columns are endmember spectra
%Error - RSMEreg error as in ICE
%extiReason - gives reason  for alg. termination
%figHandles - handle to all figures created by alg

D = size(pixelData,1);
N = size(pixelData,2);


%create albedo & reflectance conversion Structure
angleEmergence =0;
angleIncidence =0;

conversionStruct.mu = cosd(angleEmergence);
conversionStruct.mu0 = cosd(angleIncidence);



% [startingEndmembers ~, ~] = VCA( pixelData, 'Endmembers', M);
if vcaEndmembers == 1
    [endmembers ~, ~] = VCA( pixelData, 'Endmembers', M);
else
    endmembers=double(startingEndmembers);
end
dataW = zeros(D,N);
parfor i=1:N
    dataW(:,i) = lookupAlbedo2(pixelData(:,i), conversionStruct);
end

[P, F, Error, RSSsum] = unmixC4MModel2(endmembers, pixelData, dataW, mu, conversionStruct);

if vcaEndmembers == 0
    exitReason = 1;
    h=waitbar(0,'CM3:  Please wait...');
    maxIterations=120;
    %iteratively train the model
    for countIter = 1:maxIterations
        waitbar( countIter/maxIterations,h,['CM3: ', num2str(countIter), '/', num2str(maxIterations)]);
       %   fprintf('Iteration: %i, Error: %2.12f, Microscopic Prop: %2.12f\n', countIter, Error, mean(P(4,:)));
        prevError = Error;
        Estep = 0;
        
        for j=1:M
            
            W = zeros(D,M);
            parfor i=1:M
                W(:,i) =  lookupAlbedo2(endmembers(:,i), conversionStruct);
            end
            
            %update endmembers
            derFunc = zeros(D,1);
            secondDer = zeros(D,1);

                derivativeOfAlbedoOfEndmember = slopeOfInverseReflectanceCurve2(endmembers(:,j), conversionStruct);

                %added to slice variables for parfor loop
                sliceP = P(M+1,:);
                largeSliceP = P(1:M,:);
                sliceF = F(j,:);
                
                
                
            parfor i=1:N  
                derivativeOfReflectanceFunction = slopeOfReflectanceCurve2(W*F(:,i), conversionStruct);
                
%                 derFunc = derFunc + (P(j,i) + P(M+1,i).*F(j,i).*derivativeOfReflectanceFunction.*derivativeOfAlbedoOfEndmember).*(pixelData(:,i) - endmembers*P(1:M,i) - P(M+1,i).*convertToReflectance2(W*F(:,i), conversionStruct));
%                 
%                 secondDer = secondDer + (P(j,i) + P(M+1,i).*F(j,i).*derivativeOfReflectanceFunction.*derivativeOfAlbedoOfEndmember).^2;
                
                derFunc = derFunc + (P(j,i) + sliceP(:,i).*sliceF(:,i).*derivativeOfReflectanceFunction.*derivativeOfAlbedoOfEndmember).*(pixelData(:,i) - endmembers*largeSliceP(:,i) - sliceP(:,i).*convertToReflectance2(W*F(:,i), conversionStruct));
                
                secondDer = secondDer + (P(j,i) + sliceP(:,i).*sliceF(:,i).*derivativeOfReflectanceFunction.*derivativeOfAlbedoOfEndmember).^2;
                
            end
            
            derivativeOfFunction = (-2).*((1-mu)/N).*derFunc;
            
            scalingParams= 2*(mu/(M*(M-1)));
            for k=1:M
                if j ~= k
                    derivativeOfFunction = derivativeOfFunction + scalingParams.*(endmembers(:,j) - endmembers(:,k));
                end
            end
            
            secondDerivative = 2.*((1-mu)/N).*secondDer + 2*(mu/(M*(M-1)))*(M-1);
            derivativeOfFunction = derivativeOfFunction./secondDerivative;
            
            eta = 10;
            %eta = 1e-8;
            newStep = 0;
            while(eta > 1e-8)
                
                tempEndmembers = endmembers;
                tempEndmembers(:,j) = endmembers(:,j) - eta*derivativeOfFunction;
                [newP, newF, newError, newRSSsum] = unmixC4MModel2(tempEndmembers, pixelData, dataW, mu, conversionStruct);
                
                
                pass =0;
%                 if sum(tempEndmembers(:,j)<0) ~= 0
% %                     fprintf('-');
%                 elseif sum(tempEndmembers(:,j)>1) ~= 0
% %                     fprintf('1');
%                 else
                    pass =1;
%                end
                
                if newError < Error && pass == 1
                    P = newP;
                    F = newF;
                    RSSsum = newRSSsum;
                    Error = newError;
                    endmembers(:,j) = tempEndmembers(:,j);
%                      fprintf('Step for endmember %i reduced error (new
%                      error: %2.22f, eta: %2.22f)!!\n', j, Error, eta);
                    newStep = 1;
                    Estep = 1;
                    break;
                elseif pass == 1
%                      fprintf('.');
                end
                eta = eta/learningDivide;
            end
            if newStep ~= 1
%                  fprintf('\n');
            end
            
        end
        if Estep == 0;
%              fprintf('No step was made!!!\n');
            exitReason = 2;
            break;
        end
        
        if prevError - Error < 1e-7
%              fprintf('Error change was below the threshold!!!\n');
            exitReason = 3;
            break;
        end
        
    end
%     fprintf('Done! Error: %2.12f\n', Error);
    close(h);
end
Error=RSSsum;
%code to create figs
% PlotMU = mean(pixelData, 2);
% X = pixelData - repmat(PlotMU, 1, size(pixelData,2));
% dataCov = cov(X');
% [V,Diag] = eig(dataCov);
% projMat = V(:,[end, end-1, end - 2]);
% diaD = diag(Diag);
% stdDev = sqrt(diaD([end, end - 1, end - 2]));
% dataToPlot = projMat'*X;
% dataToPlot = dataToPlot./repmat(stdDev, 1, N);
% 
% Xe = endmembers - repmat(PlotMU, 1, M);
% Xe = projMat'*Xe;
% Xe = Xe./repmat(stdDev, 1, M);
% 
% %plot 3D scatter
% figHandles(1) = figure();
% scatter3(dataToPlot(1,:), dataToPlot(2,:), dataToPlot(3,:),'bx');
% hold on;
% plotL(1) = scatter3(Xe(1,1), Xe(2,1), Xe(3,1),'ro', 'LineWidth', 3);
% plotL(2) = scatter3(Xe(1,2), Xe(2,2), Xe(3,2),'go', 'LineWidth', 3);
% if M>= 3
%     plotL(3) = scatter3(Xe(1,3), Xe(2,3), Xe(3,3),'ko', 'LineWidth', 3);
%     legend(plotL, 'Endmember 1', 'Endmember 2', 'Endmember 3');
% else
%     legend(plotL, 'Endmember 1', 'Endmember 2');
% end
% xlabel('Largest Eigenvalue');
% ylabel('2nd Largest Eigenvalue');
% zlabel('3rd Largest Eigenvalue');
% 
% %plot 2D scatter 1st & 2nd eigenvectors
% figHandles(2) = figure();
% scatter(dataToPlot(1,:), dataToPlot(2,:),'bx');
% hold on;
% plotL(1) = scatter(Xe(1,1), Xe(2,1),'ro', 'LineWidth', 3);
% plotL(2) = scatter(Xe(1,2), Xe(2,2),'go', 'LineWidth', 3);
% 
% 
% if M>= 3
%     plotL(3) = scatter(Xe(1,3), Xe(2,3),'ko', 'LineWidth', 3);
%     legend(plotL, 'Endmember 1', 'Endmember 2', 'Endmember 3');
% else
%     legend(plotL, 'Endmember 1', 'Endmember 2');
% end
% 
% xlabel('Largest Eigenvalue');
% ylabel('2nd Largest Eigenvalue');
% 
% %plot 2D scatter 1st & 3rd eigenvectors
% figHandles(3) = figure();
% scatter(dataToPlot(1,:), dataToPlot(3,:),'bx');
% hold on;
% plotL(1) = scatter(Xe(1,1), Xe(3,1),'ro', 'LineWidth', 3);
% plotL(2) = scatter(Xe(1,2), Xe(3,2),'go', 'LineWidth', 3);
% if M>= 3
%     plotL(3) = scatter(Xe(1,3), Xe(3,3),'ko', 'LineWidth', 3);
%     legend(plotL, 'Endmember 1', 'Endmember 2', 'Endmember 3');
% else
%     legend(plotL, 'Endmember 1', 'Endmember 2');
% end
% xlabel('Largest Eigenvalue');
% ylabel('3rd Largest Eigenvalue');
% 
% %plot images of P, F, t
% figHandles(4) = figure();
% subplot(2,1,1)
% imagesc(P);
% title('P')
% 
% subplot(2,1,2)
% imagesc(F);
% title('F');

end
