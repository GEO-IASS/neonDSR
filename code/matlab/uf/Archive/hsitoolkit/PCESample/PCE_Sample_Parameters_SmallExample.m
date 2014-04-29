function [Parameters] = PCE_Sample_Parameters_SmallExample(X)

% [Parameters] = PCE_Sample_Parameters_DifferentWay(X)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     The Parameters                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Parameters.NumberIterations = 50000;

%Parameters for Endmembers
Parameters.MaxNumEMs = 3;
Parameters.ECovariance = .001; %Currently diagonal co-variance, same for all endmembers

%Parameters for Prior on Endmembers
Parameters.EPriorPriorCovariance = var(X(:));
Parameters.MeanData = mean(X);

%Parameters for Sampling Proportions
Parameters.AlphaPropVector = ones(1, Parameters.MaxNumEMs);

%Parameters for Sampling Endmembers
D =  sort(pdist2(X,X));
Parameters.VarianceEndmemberSampleBroad = mean(D(round(size(D,1)/2),:))^2;
Parameters.VarianceEndmemberSampleNarrow = 0.1*mean(D(2,:))^2;
Parameters.EndmemberMixedDistWeightBroad = .4;
Parameters.df = size(X,2)*2;  %scale on inverse wishart for endmember prior covariance of each convex region

%Parameters for Sampling Partitions
Parameters.NumESamples = 5;
InitialNumberOfClusters = 2
Parameters.Innovation = Parameters.NumESamples./size(X,1);

%Parameters for Sample Trace Version & Endmember Clustering/Histogram
Parameters.CompressedSampleTraceFlag = 1;
Parameters.NumInitalSampleTraceLocations = 20;
Parameters.ClusterEndmemberFlag = 0;
Parameters.ClusteringInitialCovariance = mean(D(4,:))^2;
Parameters.ClusteringDistanceThreshold = 5;
Parameters.DistanceHistogramBins = [0:.001:2]';

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Initialize Labels                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[Parameters.L, ~, v]    = EMGaussianCluster(X,InitialNumberOfClusters);
fprintf('Initializing Labels...\n');
[Parameters.L, ~, v]    = EMGaussianClusterDifferentWay(X,InitialNumberOfClusters);
InitialNumberOfClusters = max(Parameters.L)

%[Parameters.L, C] = kmeans(X,InitialNumberOfClusters); %Initialize cluster means
%for i = 1:InitialNumberOfClusters
%    v(:,:,i) = cov(X(Parameters.L == i,:)); %Initialize cluster full covariance
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Initialize Proportions                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:InitialNumberOfClusters
    Parameters.P(:,:,i) = DirichletSample(Parameters.AlphaPropVector, size(X,1));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Parameters for sampling Covariance                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Parameters.B =  eye(size(X,2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Initialize Covariance                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for i = 1:InitialNumberOfClusters
    Parameters.C = v; %This is covariance!
    Parameters.beta = 250*mean(v(:)); %scale on the sampled covariance matrix
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Initialize Endmembers                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:InitialNumberOfClusters
    
    locations = find(Parameters.L == i);
    if(length(locations) < Parameters.MaxNumEMs)
        Parameters.E(:,:,i) = X(locations,:);
        for j = length(locations)+1:Parameters.MaxNumEMs
            keyboard; %this case has not yet been coded
        end
    else        
        [Ae, ~, ~] = VCA(X(locations,:)','Endmembers', Parameters.MaxNumEMs);
        Parameters.E(:,:,i) = Ae';
        Parameters.EPriorMean(i,:) = mean(X(locations,:));
    end
       
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





end
%%
function [samples] = DirichletSample(alpha, numSamples)
    if(size(alpha,1) == 1)
        Y = randg(repmat(alpha, [numSamples,1]));
        samples = Y./repmat(sum(Y')', [1, length(alpha)]);
    else
        Y = randg(alpha);
        samples = Y./repmat(sum(Y')', [1, size(alpha,2)]);
    end
end


