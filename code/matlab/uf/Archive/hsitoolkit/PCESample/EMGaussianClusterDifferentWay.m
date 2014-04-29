function [L, C, V] = EMGaussianClusterDifferentWay(InputData, NumClusters)
%%
% EM Clustering with Gaussian Mixtures with a Full Covariance
%
% Syntax: [L, C, V] = EMGaussianCluster(InputData, NumClusters)
%
% Inputs:
%   InputData   -   NxM matrix of N data points of
%                   dimensionality M (i.e. Each data point is a row vector.)
%   NumClusters -   Desired number of clusters
%
% Outputs:
%   L           -   Vector of clusters labels for each data point, Label is
%                   determined by assigning each data point to the cluster
%                   with the highest P(Cj|xi)
%   C           -   RxM matrix of R Gaussian cluster means with
%                   dimensionality M
%   V           -   MxMxR matrix of R full covariance matrices for each
%                   Gaussian cluster of size MxM
%   


%%%%%%%%%
%%%NEED A ROBUST VERSION!!!

%%
%INITIALIZE CLUSTERS
fprintf('Building Initial Clusters Using K-Means...\n');
NumDimensions    = size(InputData, 2);
TooFewElements   = 5;
NumSmallClusters = NumClusters;
SizeClust        = zeros(NumClusters, 1);
while ((NumSmallClusters>0) && (NumClusters > 1))
    [L, C]           = kmeans(InputData,NumClusters); %Initialize cluster means
    NumSmallClusters = 0;
    for ClustNum = 1:NumClusters
        SizeClust(ClustNum) = sum(L == ClustNum);
        if (SizeClust(ClustNum) < TooFewElements)
            NumSmallClusters = NumSmallClusters + 1;
        end
    end
    NumClusters = NumClusters-NumSmallClusters;
end
SizeClust = SizeClust(1:NumClusters);
fprintf('Number of Initial Clusters = %d\n', NumClusters);
fprintf('Number of Points per Cluster = \n')
fprintf('%d ', SizeClust(1:NumClusters));
fprintf('\n');
        

InitConds = zeros(NumClusters, 1);
Loader    = zeros(NumDimensions, NumDimensions);%eye(NumDimensions);
for i = 1:NumClusters
    V(:,:,i)     = cov(InputData(L == i,:))+Loader; %Initialize cluster full covariance
    InitConds(i) = cond(V(:, :, i));
end
fprintf('Initial Condition Numbers =\n');
fprintf(' %d ', round(InitConds));
fprintf('\n');

%INITIALIZE PARAMETERS
condThresh       = 100000;%20000; %max(InitConds) %40000 %Matrix condition check threshold
iter             = 0; %Iteration Count
MAXITERS         = 30;
continueFlag     = 1; %Stopping criteria flag
NumPoints        = size(InputData,1); %Number of data points
NumDimensions    = size(InputData,2); %Data dimensionality
mixProp          = 1/NumClusters * ones(1, NumClusters); %Initialize mixing proportions
convergeThresh   = 1e-4;
maxNumIterations = 10000;
OnesNumPoints    = ones(NumPoints, 1);
pCX              = zeros(NumPoints, NumClusters);
SingValThresh    = 0.001;

while( continueFlag && (iter < MAXITERS))
    fprintf('Iteration %d...\n', iter)
    
    %CALCULATE PROBABILITY OF EACH CLUSTER C FOR EACH DATAPOINT X, pCX = p(C|X)
    pCX = 0*pCX(:, 1:NumClusters);
    for i = 1:NumClusters
%         try
%            pCX(:,i) = mvnpdf(InputData,C(i,:),V(:,:,i)).*mixProp(OnesNumPoints,i);
%         catch
           diff                   = (InputData - C(OnesNumPoints*i,:));
           ViInv                  = pinv(V(:, :, i));
           SingVals               = svd(V(:, :, i));
           TinySingVals           = SingVals<SingValThresh;
           SingVals(TinySingVals) = 1; %So don't effect multiplication
           SqrtdetViInv           = prod(sqrt(1./SingVals));
           exponent               = (-1/2)*diag(diff*ViInv*diff');
           pCX(:,i)               = SqrtdetViInv*exp(exponent).*mixProp(OnesNumPoints,i);
           %pCX(:,i) = (sqrt(det(ViInv)))*exp((-1/2)*diag(diff*ViInv*diff')).*mixProp(OnesNumPoints,i);
%         end
    end
    pCX = max(eps, pCX); %AVOID NaNs that come from outliers when calculating pCX
    pCX = pCX./repmat(sum(pCX')', [1, NumClusters]);
    
    %UPDATE MEAN VECTORS FOR EACH CLUSTER,  C
    fprintf('Updating Means...\n');
    Cprev = C;
    for i = 1:NumClusters
        C(i,:) = sum(repmat(pCX(:,i), [1, NumDimensions]).*InputData)/sum(pCX(:,i));
    end
    
    %UPDATE COVARIANCE MATRIX FOR EACH COMPONENT, V
    fprintf('Updating Covars..\n');
    for i = 1:NumClusters
        Weight               = repmat(sqrt(pCX(:,i)), [1, NumDimensions]);
        if(any(isnan(Weight)))
            fprintf('Hit a NaN in sqrt(pCX(:, i)) for i = %d\n', i);
        end
        UnWtDiff(:, :, i)    = (InputData - C(OnesNumPoints*i,:)); %USED BELOW WHEN CHECKING FOR SMALL CLUSTERS
        Diff(:,:,i)          = Weight.*UnWtDiff(:, :, i);
    end
    for i = 1:NumClusters
        V(:,:,i) = (Diff(:,:,i)'*Diff(:,:,i))/sum(pCX(:,i));
    end
    
    %CHECK FOR SMALL CLUSTERS
    %
    %FIRST COMPUTE MAHALANOBIS DISTANCES FROM ALL POINTS TO ALL CLUSTERS
    fprintf('Checking for Small Clusters...\n');
    MahalanobisDists = zeros(NumPoints, NumClusters);
    rFlag            = zeros(1, NumClusters);
    for ClustNum = 1:NumClusters
        InvCovar                      = pinv(V(:, :, ClustNum));
        UW                            = squeeze(UnWtDiff(:, :, ClustNum));
        MahalanobisDists(:, ClustNum) = diag(UW*InvCovar*UW');
    end
    %figure;imagesc(MahalanobisDists); title('Mahalanobis Dists');
    %drawnow
    %keyboard
    
    [MaxMemb, L] = min(MahalanobisDists');
    rFlag        = zeros(1, NumClusters);
    for ClustNum = 1:NumClusters
        SizeClust(ClustNum) = sum(L == ClustNum);
        if(SizeClust(ClustNum) < TooFewElements)
            rFlag(ClustNum) = 1;
        end
    end
    fprintf('Number of Clusters = %d\n', NumClusters);
    fprintf('Number of Points per Cluster = \n')
    fprintf('%d ', SizeClust(1:NumClusters));
    fprintf('\n');
    fprintf('Indicators of small clusters\n')
    fprintf('%d ', rFlag);
    fprintf('\n');
    
    %REMOVE CLUSTERS WITH TOO FEW ELEMENTS AND REINITIALIZE THE MEANS AND COVARIANCES.
    if(sum(rFlag) > 0)
        fprintf('Removing %d clusters...\n', sum(rFlag));
        
        %STOP IF ONLY ONE CLUSTER LEFT
        NumClusters = NumClusters - sum(rFlag);
        if (NumClusters == 1)
            continueFlag = 0;
        else
        %OTHERWISE JUST KEEP DISTANCES FROM ALL POINTS TO THE REMAINING CLUSTERS AND ASSIGN LABELS BASED ON THOSE    
        rFlag            = logical(1-rFlag);
        MahalanobisDists = MahalanobisDists(:, rFlag);
        [MaxMemb, L]     = min(MahalanobisDists');
        %UPDATE CLUSTER MEMBERSHIPS AND PARAMETERS
        for i = 1:NumClusters
            Clusteri               = InputData(L == i, :);
            C(i, :)                = mean(Clusteri);
            V(:,:,i)               = cov(Clusteri);
            diff                   = (InputData - C(OnesNumPoints*i,:));
            ViInv                  = pinv(V(:, :, i));
            SingVals               = svd(V(:, :, i));
            TinySingVals           = SingVals<SingValThresh;
            SingVals(TinySingVals) = 1; %So doesn't effect multiplication
            SqrtdetViInv           = prod(sqrt(1./SingVals));
            exponent               = (-1/2)*diag(diff*ViInv*diff');
            pCX(:,i)               = SqrtdetViInv*exp(exponent).*mixProp(OnesNumPoints,i);
        end
        pCX   = max(eps, pCX); %AVOID NaNs that come from outliers when calculating pCX
        Cprev = zeros(size(C));
        end
    end
    
    %Update Mixing Proportions
    mixProp = (1/NumPoints)*sum(pCX); %IS THIS RIGHT?  I GUESS SO
    
    %Check Stopping Criteria
    if(  norm(C - Cprev) < convergeThresh || iter > maxNumIterations )
        continueFlag = 0;
    end
    
    %Update Iteration Count
    iter = iter + 1;
end

V = V(:, :, 1:NumClusters);
L = L';
%SHOULDN'T NEED THIS AS L IS COMPUTED ABOVE
% MahalanobisDists = zeros(NumPoints, NumClusters);;
%     for ClustNum = 1:NumClusters
%         diff      = (InputData - C(OnesNumPoints*ClustNum,:));
%         InvCovar  = pinv(V(:, :, ClustNum));
%         MahalanobisDists(:, ClustNum) = diag(diff*InvCovar*diff');
%     end
% [MaxMemb, L] = min(MahalanobisDists');


%[maxV, L] = max(pCX, [], 2);