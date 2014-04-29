function [P, F, t, endmembers, Error, exitReason, figHandles] = EM4( pixelData, M, mu, startingEndmembers, learningDivide)
figHandles=[];
%input
%pixelData - input hyperspectral pixel data column vectors are pixel spectra (DxN)
%M - number of endmembers to find in data
%mu - parameter controlling error between RSS & SDD term
%startingEndmembers - given starting endmembers, use random pixels if not given (DxM)

%output
%P - proportions of macroscopic mixture, colum vectors are endmember proportions for the given pixel
%F - proportions of microscopic mixture, colum vectors are endmember proportions for the given pixel
%t - proportion of mixture belonging to given mixture type
%endmember - extracted endmembers from data, columns are endmember spectra
maxIterations = 120;
D = size(pixelData,1);
N = size(pixelData,2);
exitReason = 1;


%create albedo & reflectance lookup tables for future use
[conversionStruct] = createStructForReflAlbedoConversion( 0, 0);
parfor i=1:N
    dataW(:,i) = lookupAlbedo2(pixelData(:,i), conversionStruct);
end
endmembers = startingEndmembers;
[P, F, t, Error, RSSerror] = unmixEM4(endmembers, pixelData, dataW, mu, conversionStruct);
h=waitbar(0,'EM4: Please wait...');
%iteratively train the model
for countIter = 1:maxIterations
    waitbar( countIter/maxIterations,h,['EM4: ', num2str(countIter), '/', num2str(maxIterations)]);
%           fprintf('Iteration: %i, Error: %2.12f, Microscopic: %3.3f\n',  countIter, Error, sum(t(2,:))/size(t,2));
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

        parfor i=1:N
            derivativeOfReflectanceFunction = slopeOfReflectanceCurve2(W*F(:,i), conversionStruct);
            
            derFunc = derFunc + t(1,i).*P(j,i).*(pixelData(:,i) - endmembers*P(:,i)) + ...
                t(2,i).*F(j,i).*derivativeOfReflectanceFunction.*derivativeOfAlbedoOfEndmember.*(pixelData(:,i) - convertToReflectance2(W*F(:,i), conversionStruct));
            
            secondDer = secondDer + t(1,i)*P(j,i)^2 + t(2,i).*(F(j,i).*derivativeOfReflectanceFunction.*derivativeOfAlbedoOfEndmember).^2;
            
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
        newStep = 0;
        while(eta > 1e-8)
            
            tempEndmembers = endmembers;
            tempEndmembers(:,j) = endmembers(:,j) - eta*derivativeOfFunction;
           
            [newP, newF, newt, newError, newRSSerror] = unmixEM4(tempEndmembers, pixelData, dataW, mu, conversionStruct);
            pass =0;
%             if sum(tempEndmembers(:,j)<0) ~= 0
% %                                  fprintf('-');
%             elseif sum(tempEndmembers(:,j)>1) ~= 0
% %                                  fprintf('1');
%             else
                pass =1;
%              end
            
            if newError < Error && pass == 1
                P = newP;
                F = newF;
                t = newt;
                RSSerror=newRSSerror;
                Error = newError;
                endmembers(:,j) = tempEndmembers(:,j);
%                                   fprintf('Step for endmember %i reduced error (new error: %2.22f, eta: %2.22f)!!\n', j, Error, eta);
                newStep = 1;
                Estep = 1;
                break;
            elseif pass == 1
%                                  fprintf('.');
            end
            eta = eta/learningDivide;
        end
        if newStep ~= 1
%                           fprintf('\n');
        end
        
    end
    if Estep == 0;
%                  fprintf('No step was made!!!\n');
        exitReason = 2;
        break;
    end
    
    if prevError - Error < 1e-7
%                  fprintf('Error change was below the threshold!!!\n');
        exitReason = 3;
        break;
    end
    
end
%  fprintf('Done! Error: %2.12f\n', Error);
Error = RSSerror;
close(h);
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
% subplot(3,1,1)
% imagesc(P);
% title('P')
% 
% subplot(3,1,2)
% imagesc(F);
% title('F');
% 
% subplot(3,1,3)
% imagesc(t);
% title('t');
end
