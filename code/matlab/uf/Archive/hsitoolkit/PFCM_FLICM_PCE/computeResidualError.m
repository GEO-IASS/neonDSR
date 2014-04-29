function [resError] = computeResidualError(R);

dataFolder = '/Users/alina/Documents/MATLAB/Datasets/Eyes/HyperspectralEyeTrainingDataStructs/';

Eye = 1;

for i = 1:size(R,1);
   
    %Load Data
    load([dataFolder, R(i,1).name]);
    
    %pca
    Data = reshape(EyeImsStruct(Eye).HSIEyeIms, size(EyeImsStruct(Eye).HSIEyeIms,1)*size(EyeImsStruct(Eye).HSIEyeIms,2), size(EyeImsStruct(Eye).HSIEyeIms,3));
    [t, Data] = princomp(Data);
    Data = Data(:,1:3);
    Data = Data - min(Data(:));
    Data = Data / max(Data(:));
    
    
    for k = 1:size(R,2);
        ProdValue = [];
        for j = 1:length(R(i,k).P)
            ProdValue = horzcat(ProdValue, R(i,k).P{j}.*repmat(R(i,k).U(j,:)', [1 size(R(i,k).P,2)]).*repmat(R(i,k).T(j,:)', [1 size(R(i,k).P,2)]));
        end
        
        EE = [];
        for j = 1:length(R(i,k).E);
            EE = vertcat(EE, R(i,k).E{j});
        end
        
        resError(i,k) = sum(sum((Data - ProdValue*EE).*(Data - ProdValue*EE)))/size(Data,1);
        
    end
end