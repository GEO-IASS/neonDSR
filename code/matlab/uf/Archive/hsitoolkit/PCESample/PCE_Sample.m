function [LogLikelihoodTrace, SampleTrace, ClusterResults] = PCE_Sample(X, Parameters)

stepThroughFlag = 0;
%%
%-------------------------------------------------------------%
%          Initialize and Precompute Constants                %
%-------------------------------------------------------------%
%Initialize Endmembers, Proportions, Lables, PriorCovariance & PriorMeans
E          = Parameters.E;  % n_em x n_dim x n_cluster
P          = Parameters.P;  % n_pt x n_em x n_cluster
L          = Parameters.L;  % n_pt x 1
C          = Parameters.C;  % n_dim x n_dim x n_cluster
EPriorMean = Parameters.EPriorMean; % n_cluster x n_dim

%Initialize Loglikelihood trace & number of points per partition
LogLikelihoodTrace  = zeros(Parameters.NumInitalSampleTraceLocations,Parameters.NumberIterations);
NumPointsPerCluster = zeros(1,size(E,3));
for i = 1:size(E,3)
    NumPointsPerCluster(i) = sum(L == i);
end

%Precompute constants
NPts                  = size(X,1);
Denominator           = NPts-1+Parameters.Innovation;
LogDenom              = log(Denominator);
MeanSet               = repmat(Parameters.MeanData, [Parameters.NumESamples, 1]);
onesLengthAlpha       = ones(1, Parameters.MaxNumEMs);
Dims                  = size(X,2);

%Initialize Sample Trace
numC = size(E,3);
SampleTrace(1,Parameters.NumInitalSampleTraceLocations) = struct( 'E', zeros(size(E)), 'EPriorMean', zeros(size(EPriorMean)), 'P', zeros(size(P)), 'L',zeros(size(L)), 'C', zeros(size(C)), 'ClusterSizeFrequency', 0, 'LikelihoodValue', -1*inf);
SampleTrace(numC).E                     = E;
SampleTrace(numC).P                     = P;
SampleTrace(numC).L                     = L;
SampleTrace(numC).C                     = C;
SampleTrace(numC).EPriorMean            = EPriorMean;
SampleTrace(numC).ClusterSizeFrequency  = 1;
SampleTrace(numC).LikelihoodValue       = -1*inf;

%Initialize Endmember Cluster Tracking
if(Parameters.ClusterEndmemberFlag)
    ClusterMeans        = reshape(shiftdim(E,1), [Parameters.MaxNumEMs*numC, Parameters.MaxNumEMs]);
    ClusterCovariances  = zeros(Dims, Dims, numC*Parameters.MaxNumEMs);
    ClusterCounts       = ones(1,numC*Parameters.MaxNumEMs);
    for i = 1:numC*Parameters.MaxNumEMs
        ClusterCovariances(:,:,i)   = eye(Dims)*Parameters.ClusteringInitialCovariance;
    end
end
ClusterResults.DistanceHistogram = zeros(1,size(Parameters.DistanceHistogramBins,1));


%Initialize all Likelihood and Prior Values
Z                         = createZMatrix(L);
LogLikelihoodOld          = ComputeLogLikelihoodAll(X, E, P, Parameters, NPts);
EpriorOld                 = ComputeEPriorForAPartition(E, EPriorMean, C, Parameters.beta);
EpriorpriorOld            = ComputeEPriorPrior( EPriorMean, Parameters);
PpriorOld                 = ComputePPriorForAPartition(P, Parameters);
CpriorOld                 = ComputeCPrior(C, Parameters);
LogLikelihoodTrace(size(E,3), 1)     = sum(sum(LogLikelihoodOld.*Z)) + sum(sum(EpriorOld)) + sum(sum(EpriorpriorOld)) + sum(sum(PpriorOld.*Z)) + sum(sum(CpriorOld)) ;
acceptRate                = 0;
acceptRateDenom           = 0;
tic;
%-------------------------------------------------------------%
%-------------------------------------------------------------%



%%
for iteration = 2:Parameters.NumberIterations+1
    
    for k = 1:numC
        %%
        
        
        %-------------------------------------------------------------%
        %                    Update Proportions                       %
        %-------------------------------------------------------------%
        Y                     = randg(Parameters.AlphaPropVector(1), NPts, Parameters.MaxNumEMs) ; %Sample proportions under consideration
        v                     = sum(Y,2);
        samples               = Y./v(:, onesLengthAlpha);
        LogLikelihoodNew      = ComputeLogLikelihoodAll(X, E(:,:,k), samples, Parameters, NPts);
        Ratios                = exp(LogLikelihoodNew - LogLikelihoodOld(:,k));
        rands                 = rand(NPts,1);
        Vals                  = rands < Ratios;
        Vrep                  = Vals(:, onesLengthAlpha);
        P(:,:,k)              = samples.*Vrep  + P( :,:,k).*(1-Vrep);
        LogLikelihoodOld(:,k) = (1-Vals).*LogLikelihoodOld(:,k) + (Vals).*LogLikelihoodNew;
        %-------------------------------------------------------------%
        %-------------------------------------------------------------%
        
        
        %%
        %-------------------------------------------------------------%
        %                    Update Endmembers                        %
        %-------------------------------------------------------------%
        
        % ---- from inlined call to ComputeLogLikelihoodAll ----
        Pk = P(:,:,k); 
        C_ll = (-1/2)*1./sum(Pk.*Pk*Parameters.ECovariance,2); 
        N_ll = -1*log(squeeze(sum(Pk.*Pk*Parameters.ECovariance,2)).*Dims);
        % ------------------------------------------------------
        
        C_inv_pp = pinv(Parameters.beta.*C(:,:,k)); % for inlined call to ComputeEPriorForAPartition
        
        randOrder = randperm(Parameters.MaxNumEMs);
        for j = randOrder
            for n = 1:Dims
                rands = rand(1);
                if(rands <= Parameters.EndmemberMixedDistWeightBroad)
                    [samples] = sampleEndmemberFromGaussian(E(j,n,k), Parameters.VarianceEndmemberSampleBroad);
                else
                    [samples] = sampleEndmemberFromGaussian(E(j,n,k), Parameters.VarianceEndmemberSampleNarrow);
                end
                Esample               = E;
                Esample(j,n,k)        = samples;
                %LogLikelihoodNew      = ComputeLogLikelihoodAll(X, Esample(:,:,k), P(:,:,k), Parameters, NPts);
                
                % ---- inlined/optimized call to ComputeLogLikelihoodAll ---- 
                Recon = Pk*Esample(:,:,k);
                D = sum((X - Recon).^2,2);
                LogLikelihoodNew = N_ll + C_ll.*D;                
                % -----------------------------------------------------------
                
                EpriorNew             = EpriorOld;
                %EpriorNew(k,j)        = ComputeEPriorForAPartition(Esample(j,:,k), EPriorMean(k,:), C(:,:,k), Parameters.beta);
                
                % ---- inlined/optimized call to ComputeEPriorForAPartition ----                           
                diff = Esample(j,:,k) - EPriorMean(k,:);
                EpriorNew(k,j) = -(1/2)*diff*C_inv_pp*diff';
                % -----------------------------------------------------------                
                
                a                     = exp((sum(LogLikelihoodNew.*Z(:,k))+ sum(EpriorNew(k,:))) - (sum(LogLikelihoodOld(:,k).*Z(:,k)) + sum(EpriorOld(k,:))));
                rands                 = rand(1);
                acceptRateDenom       = acceptRateDenom + 1;
                if( rands < a )
                    acceptRate                              = acceptRate+1;
                    E                                       = Esample;
                    LogLikelihoodOld(:,k)                   = LogLikelihoodNew;
                    diff                                    =  sqrt(sum(sum((EpriorOld - EpriorNew).^2)));
                    loc                                     =  find(Parameters.DistanceHistogramBins < diff, 1, 'last');
                    ClusterResults.DistanceHistogram(loc)   = ClusterResults.DistanceHistogram(loc) + 1;
                    EpriorOld                               = EpriorNew;
                end
            end
        end
        %-------------------------------------------------------------%
        %-------------------------------------------------------------%
        
        
        
        %%
        %-------------------------------------------------------------%
        %             Update Endmember Prior Means                    %
        %-------------------------------------------------------------%
        for n = 1:Dims
            rands = rand(1);
            if(rands <= Parameters.EndmemberMixedDistWeightBroad)
                [samples] = sampleEndmemberFromGaussian(EPriorMean(k,n), Parameters.VarianceEndmemberSampleBroad);
            else
                [samples] = sampleEndmemberFromGaussian(EPriorMean(k,n), Parameters.VarianceEndmemberSampleNarrow);
            end
            Esample = EPriorMean;
            Esample(k,n) = samples;
            EpriorNew = EpriorOld;
            EpriorpriorNew = EpriorpriorOld;
            EpriorNew(k,:) = ComputeEPriorForAPartition(E(:,:,k), Esample(k,:), C(:,:,k), Parameters.beta);
            EpriorpriorNew(k,:) = ComputeEPriorPrior(Esample(k,:), Parameters);
            a = exp(sum(sum(EpriorNew)) + sum(sum(EpriorpriorNew)) - sum(sum(EpriorOld)) - sum(sum(EpriorpriorOld)));
            rands = rand(1);
            if( rands < a )
                EPriorMean = Esample;
                EpriorOld = EpriorNew;
                EpriorpriorOld = EpriorpriorNew;
            end
        end
        %-------------------------------------------------------------%
        %-------------------------------------------------------------%
        
        
        
        %%
        %-------------------------------------------------------------%
        %          Update Endmember Prior Covariances                 %
        %-------------------------------------------------------------%
        [samples] = iwishrnd(Parameters.B,Parameters.df);
        Csample = C;
        Csample(:,:,k) = samples;
        EpriorNew = EpriorOld;
        EpriorNew(k,:) = ComputeEPriorForAPartition(E(:,:,k), EPriorMean(k,:), Csample(:,:,k), Parameters.beta);
        a = exp(sum(sum(EpriorNew))  - sum(sum(EpriorOld)));
        rands = rand(1);
        if( rands < a)
            C = Csample;
            CpriorOld = ComputeCPrior(C, Parameters);
            EpriorOld = EpriorNew;
        end
        %-------------------------------------------------------------%
        %-------------------------------------------------------------%
    end
    PpriorOld = ComputePPriorForAPartition(P, Parameters);
    
    
    
    %%
    %-------------------------------------------------------------%
    %                       Update Labels                         %
    %-------------------------------------------------------------%
    ProbsOldBase = log(NumPointsPerCluster) - LogDenom + sum(EpriorOld,2)' + sum(EpriorpriorOld,2)' + CpriorOld + sum(PpriorOld);
    
    %Sample New C for New Clusters
    clear Csample
    for i = 1:Parameters.NumESamples
        [Csample(:,:,i)] =  iwishrnd(Parameters.B,Parameters.df);
    end
    
    %Sample New EPriorMean for New Clusters
    [epsamples] = sampleEndmemberSets(MeanSet, eye(size(MeanSet,2))*Parameters.EPriorPriorCovariance);
    
    clear samples;
    psamples = zeros(NPts, Parameters.MaxNumEMs, Parameters.NumESamples);
    for i = 1:Parameters.NumESamples;
        %Sample New Endmembers for New Clusters
        v                = epsamples(i,:);
        [samples(:,:,i)] = sampleEndmemberSets( v(ones(Parameters.MaxNumEMs,1),:), Parameters.beta*Csample(:,:,i));
        
        %Sample New Proportions for New Clusters
        Y                = randg(Parameters.AlphaPropVector(1), NPts, Parameters.MaxNumEMs) ; %Sample proportions under consideration
        v                = sum(Y,2);
        psamples(:,:,i)  = Y./v(:, onesLengthAlpha);
    end
    
    %Compute Likelihoods in New Clusters
    [LogLikelihoodNew] = ComputeLogLikelihoodAll(X, samples, psamples, Parameters, NPts);
    EpriorpriorNew     = ComputeEPriorPrior(epsamples, Parameters);
    CpriorNew          = ComputeCPrior(Csample, Parameters);
    EpriorNew          = ComputeEPriorForAPartition(samples, epsamples, Csample, Parameters.beta);
    PpriorNew          = ComputePPriorForAPartition(psamples, Parameters);
    ProbsNew           = log(Parameters.Innovation/Parameters.NumESamples) - LogDenom + sum(EpriorNew,2)' + sum(EpriorpriorNew, 2)' + CpriorNew + sum(PpriorNew);
    ProbsNew           = ProbsNew(ones(NPts,1),:) + LogLikelihoodNew;
    
    %     Innovation = [log(NumPointsPerCluster), log(Parameters.Innovation/Parameters.NumESamples)] - LogDenom
    %     EndmemberPrior = [sum(EpriorOld,2)', sum(EpriorNew,2)' ]
    %     EndmemberCenterPrior = [sum(EpriorpriorOld,2)', sum(EpriorpriorNew, 2)']
    %     ClusterCovariancePrior = [CpriorOld, CpriorNew ]
    %     %[sum(PpriorOld), sum(PpriorNew)]
    %     LikelihoodMean = mean([LogLikelihoodOld, LogLikelihoodNew])
    %     LikelihoodMeanP
    %     LikelihoodMeanP = LikelihoodMean;
    %     keyboard;
    
    rands = rand(NPts,1);
    
    randOrder    = randperm(NPts);
    for j = randOrder
        %Remove Data Point and Empty Clusters
        OldLabel = L(j);
        NumPointsPerCluster(OldLabel) = NumPointsPerCluster(OldLabel)-1;
        
        if(NumPointsPerCluster(OldLabel) == 0)
            sd                  = setdiff((1:size(E,3)), OldLabel);
            NumPointsPerCluster = NumPointsPerCluster(sd);
            P                   = P(:,:,sd);
            EPriorMean          = EPriorMean(sd,:);
            E                   = E(:,:,sd);
            C                   = C(:,:, sd);
            L(L > OldLabel)     = L(L > OldLabel)-1;
            Z                   = Z(:, sd);
            LogLikelihoodOld    = ComputeLogLikelihoodAll(X, E, P, Parameters,NPts);
            EpriorOld           = ComputeEPriorForAPartition(E, EPriorMean, C, Parameters.beta);
            PpriorOld           = ComputePPriorForAPartition(P, Parameters);
            EpriorpriorOld      = ComputeEPriorPrior( EPriorMean, Parameters);
            CpriorOld           = ComputeCPrior(C, Parameters);
            ProbsOldBase        = log(NumPointsPerCluster) - LogDenom + sum(EpriorOld,2)' + sum(EpriorpriorOld,2)' + CpriorOld + sum(PpriorOld);
            OldLabel            = -1;
            numC                = numC-1;
        end
        %L(j) = -1;
        
        %Compute Likelihoods For Existing Clusters
        ProbsOld           = ProbsOldBase + LogLikelihoodOld(j,:);
        ProbsA             = horzcat(ProbsOld, ProbsNew(j,:));
        MaxProbsA          = max(ProbsA);
        EPMinusM           = exp(ProbsA-MaxProbsA);
        Probs              = EPMinusM/sum(EPMinusM);        
        loc                = find(cumsum(Probs) >= rands(j), 1);

        % comment out below, as testing the condition for every point eats a lot of time
%         if(stepThroughFlag && iteration > 10)
%             ProbsA
%             Probs
%             disp('EPrior  old then new');
%             sum(ComputeEPriorForAPartition(E, EPriorMean, C, Parameters.beta),2)'
%             sum(ComputeEPriorForAPartition(samples, epsamples, Csample, Parameters.beta),2)'
%             disp('EPriorPrior');
%             sum(ComputeEPriorPrior( EPriorMean, Parameters),2)' 
%             sum(ComputeEPriorPrior(epsamples, Parameters),2)'
%             disp('CPrior');
%             ComputeCPrior(C, Parameters)
%             ComputeCPrior(Csample, Parameters)
%             keyboard;
%         end
                
        if(loc == OldLabel)
            %L(j)                     = loc;  % if we don't un-set L(j) to -1, we don't have to re-set here for the common case
            NumPointsPerCluster(loc) = NumPointsPerCluster(loc) + 1;            
            
        elseif(loc <= length(NumPointsPerCluster))            
            L(j)                     = loc;
            NumPointsPerCluster(loc) = NumPointsPerCluster(loc) + 1;
            Z(j,:)                   = zeros(1,size(Z,2));
            Z(j,loc)                 = 1;
            %PpriorOld                = ComputePPriorForAPartition(P, Parameters); %does not appear needed, we haven't changed P
            ProbsOldBase             = log(NumPointsPerCluster) - LogDenom + sum(EpriorOld,2)' + sum(PpriorOld) + sum(EpriorpriorOld,2)' + CpriorOld;            
            %ProbsOldBase             = log(NumPointsPerCluster) - LogDenom + sum(EpriorOld,2)' + sum(PpriorOld) + sum(EpriorpriorOld,2)';
        else
            numC                = numC +1;
            ll                  = loc-length(NumPointsPerCluster);
            L(j)                = length(NumPointsPerCluster)+1;
            P(:,:,end+1)        = psamples(:,:,ll);
            E(:,:,end+1)        = samples(:,:,ll);
            C(:,:, end+1)       = Csample(:,:,ll);
            EPriorMean(end+1,:) = epsamples(ll,:);
            NumPointsPerCluster = horzcat(NumPointsPerCluster, 1);
            LogLikelihoodOld    = ComputeLogLikelihoodAll(X, E, P, Parameters, NPts);
            EpriorOld           = ComputeEPriorForAPartition(E, EPriorMean, C, Parameters.beta);
            CpriorOld           = ComputeCPrior(C, Parameters);
            EpriorpriorOld      = ComputeEPriorPrior(EPriorMean, Parameters);
            Z                   = createZMatrix(L);
            PpriorOld           = ComputePPriorForAPartition(P, Parameters);
            ProbsOldBase        = log(NumPointsPerCluster) - LogDenom + sum(EpriorOld,2)' + sum(EpriorpriorOld,2)' + CpriorOld + sum(PpriorOld);
            sd                  = setdiff((1:size(psamples,3)), ll);
            psamples            = psamples(:,:,sd);
            samples             = samples(:,:,sd);
            Csample             = Csample(:,:, sd);
            epsamples           = epsamples(sd,:);
            [LogLikelihoodNew]  = LogLikelihoodNew(:,sd);
            EpriorpriorNew      = EpriorpriorNew(sd);
            CpriorNew           = CpriorNew(sd);
            EpriorNew           = EpriorNew(sd,:);
            PpriorNew           = PpriorNew(:,sd);
            ProbsNew            = ProbsNew(:,sd);
        end
    end
    %-------------------------------------------------------------%
    %-------------------------------------------------------------%
    
    
    
    %%
    
    %-------------------------------------------------------------%
    %                 Update Sample Trace                         %
    %-------------------------------------------------------------%
    if(length(SampleTrace) < numC)
        %Add more spots in SampleTrace
        for i = length(SampleTrace)+1:numC
            SampleTrace(i).E          = [];
            SampleTrace(i).P          = [];
            SampleTrace(i).L          = [];
            SampleTrace(i).C          = [];
            SampleTrace(i).EPriorMean = [];
            SampleTrace(i).ClusterSizeFrequency = 0;
            SampleTrace(i).LikelihoodValue       = -1*inf;
            LogLikelihoodTrace(i,:)   = 0;
        end
        %Replace current sample
        SampleTrace(numC).E          = E;
        SampleTrace(numC).P          = P;
        SampleTrace(numC).L          = L;
        SampleTrace(numC).C          = C;
        SampleTrace(numC).EPriorMean = EPriorMean;
        SampleTrace(numC).ClusterSizeFrequency = SampleTrace(numC).ClusterSizeFrequency +1;
        LogLikelihoodTrace(numC, find(LogLikelihoodTrace(numC,:)==0, 1, 'first')) = sum(sum(LogLikelihoodOld.*Z)) + sum(sum(EpriorOld)) + sum(sum(PpriorOld.*Z)) + sum(sum(EpriorpriorOld)) + sum(sum(CpriorOld));
        SampleTrace(numC).LikelihoodValue      = LogLikelihoodTrace(numC,find(LogLikelihoodTrace(numC,:)~=0, 1, 'last') );
    else
        LogLikelihoodTrace(numC, find(LogLikelihoodTrace(numC,:)==0, 1, 'first')) = sum(sum(LogLikelihoodOld.*Z)) + sum(sum(EpriorOld)) + sum(sum(PpriorOld.*Z)) + sum(sum(EpriorpriorOld)) + sum(sum(CpriorOld));
        if( isempty(SampleTrace(numC).LikelihoodValue) || (SampleTrace(numC).LikelihoodValue < LogLikelihoodTrace(iteration)));
            %Replace current sample
            SampleTrace(numC).E          = E;
            SampleTrace(numC).P          = P;
            SampleTrace(numC).L          = L;
            SampleTrace(numC).C          = C;
            SampleTrace(numC).EPriorMean = EPriorMean;
            if(isempty(SampleTrace(numC).ClusterSizeFrequency))
                SampleTrace(numC).ClusterSizeFrequency = 1;
            else
                SampleTrace(numC).ClusterSizeFrequency = SampleTrace(numC).ClusterSizeFrequency +1;
            end
            SampleTrace(numC).LikelihoodValue      = LogLikelihoodTrace(numC,find(LogLikelihoodTrace(numC,:)~=0, 1, 'last') );
        else
            %Only increment count
            SampleTrace(numC).ClusterSizeFrequency = SampleTrace(numC).ClusterSizeFrequency +1;
        end
    end
    %-------------------------------------------------------------%
    %-------------------------------------------------------------%
    
        
    %-------------------------------------------------------------%
    %                Update Endmember Cluster Tracking            %
    %-------------------------------------------------------------%
    if(Parameters.ClusterEndmemberFlag)
        eFlat = reshape(shiftdim(E,1), [Parameters.MaxNumEMs*numC, Parameters.MaxNumEMs]);
        clear dd;
        for i = 1:size(ClusterMeans,1)
            dd(i,:) = pdist2(ClusterMeans(i,:), eFlat, 'Mahalanobis', ClusterCovariances(:,:,i));
        end
        [minValues, locs] = min(dd);
        for i = 1:size(eFlat,1)
            if(minValues(i) < Parameters.ClusteringDistanceThreshold)
                %Add to an exisiting cluster and update
                diff                            = (eFlat(i,:)-ClusterMeans(locs(i),:));
                ClusterMeans(locs(i),:)         = (ClusterCounts(locs(i))*ClusterMeans(locs(i),:) + eFlat(i,:))/(ClusterCounts(locs(i))+1);
                ClusterCovariances(:,:,locs(i)) = ((ClusterCounts(locs(i))*ClusterCovariances(:,:,locs(i))) + diff'*diff)/(ClusterCounts(locs(i))+1);
                ClusterCounts(locs(i))          = ClusterCounts(locs(i)) +1;
            else
                %Start a new cluster
                ClusterMeans(end+1,:)           = eFlat(i,:);
                ClusterCovariances(:,:,end+1)   = eye(Dims)*Parameters.ClusteringInitialCovariance;
                ClusterCounts(end+1)            = 1;
            end
            
        end
        ClusterResults.ClusterMeans             = ClusterMeans;
        ClusterResults.ClusterCovariances       = ClusterCovariances;
        ClusterResults.ClusterCounts            = ClusterCounts;
    end
    %-------------------------------------------------------------%
    %-------------------------------------------------------------%
    

    %-------------------------------------------------------------%
    %                 Display Progress                            %
    %-------------------------------------------------------------%
    %disp(num2str(size(E,3)))
    if(mod(iteration, 100) == 0);
        disp(['Iteration ', num2str(iteration), ' of ', num2str(Parameters.NumberIterations)]);
        disp(['Number of clusters: ', num2str(size(E,3))]);
        disp(['Accept rate: ', num2str(acceptRate/acceptRateDenom)]);
        acceptRate       = 0;
        acceptRateDenom  = 0;
        toc
        tic;
    end
    
    if(mod(iteration, 5000) == 0);
        save TempResults;
    end
    %-------------------------------------------------------------%
    %-------------------------------------------------------------%
    
end
end

function [LogLikelihoodAll] = ComputeLogLikelihoodAll(X, E, P, Parameters, NumPoints)
% compute log likelihood of all points in all endmember sets

NumSets = size(E,3);
LogLikelihoodAll = zeros(NumPoints, NumSets);
C = (-1/2)*1./sum(P.*P*Parameters.ECovariance,2);
%N = -1*log(2*pi)*(size(X,2)/2) + -1*log(squeeze(sum(P.*P*Parameters.ECovariance,2)).*size(X,2));
N = -1*log(squeeze(sum(P.*P*Parameters.ECovariance,2)).*size(X,2));
for i = 1:NumSets
    Recon = P(:,:,i)*E(:,:,i);
    D = (X - Recon)';
    D = sum(D.*D);
    LogLikelihoodAll(:,i) = N(:,i) + C(:,1,i).*D';
end

end

function [LogPPrior] = ComputePPriorForAPartition(P, Parameters)
% compute log likelihood of proportions in each set's dirichlet prior
if( (sum(Parameters.AlphaPropVector == 1) == length(Parameters.AlphaPropVector)) )
    LogPPrior = zeros(size(P,1), size(P,3));
else
    LogPPrior = squeeze(sum(log(P).*(repmat(Parameters.AlphaPropVector-1, [size(P,1), 1, size(P,3)])),2));
end
end

function [LogCPrior] = ComputeCPrior(C, Parameters)
% compute log likelihood of each set's covariance in its inverse wishart prior
LogCPrior = zeros(1,size(C,3));
T = Parameters.B;
v = Parameters.df;
d = size(C,1);
%X = C;
%constA = (v/2)*log(det(T));
%constB = -1*(v*d/2)*log(2);
%constC = -1*((d*(d-1))/4)*log(pi);
%constD = 0;
%for i = v:-1:v-d+1
%    constD = constD + log(gamma(i/2));
%end
%constD = -1*constD;
%const = constA + constB + constC + constD;
for i = 1:size(C,3)
    %LogCPrior(i) = (-1/2*trace(T*inv(X(:,:,i)))) - ((v + d + 1) / 2)*log(det(X(:,:,i))) + const;
    LogCPrior(i) = (-1/2*trace(T*pinv(C(:,:,i)))) - ((v + d + 1) / 2)*log(det(C(:,:,i)));
end
end

function [LogEPrior] = ComputeEPriorForAPartition(E, EPriorMean, C, beta)
% computes log likelihood of each partition's endmembers
LogEPrior = zeros(size(E,3), size(E,1));
oness = ones(size(E,1),1);
for i = 1:size(E,3)
    diff = E(:,:,i) - EPriorMean(i*oness, :);
    LEP  = -(1/2)*diff*pinv(beta.*C(:,:,i))*diff';
    LogEPrior(i,:) = diag(LEP);
end
end

function [LogEPrior] = ComputeEPriorPrior( EPriorMean, Parameters)
% compute log likelihood of each endmember set mean in the global prior
LogEPrior = zeros(size(EPriorMean,1), size(EPriorMean,2));
InvCovs2 =  (-1/2)*(1./(Parameters.EPriorPriorCovariance));
for i = 1:size(EPriorMean,1)
    diff = (EPriorMean(i,:)-Parameters.MeanData);
    EPriorPrior = InvCovs2.*sum((diff.*diff),2)';
    LogEPrior(i,:) = EPriorPrior;
end
end

function [samples] = sampleEndmemberFromGaussian(meanV, covV)
[samples] = (randn([1,length(meanV)]).*covV)+meanV;
end

function [samples] = sampleEndmemberSets(meanVSet, covV)
samples = mvnrnd(meanVSet,covV);
end

function [Z] = createZMatrix(L)
T = unique(L);
T = T(:, ones(1, length(L)));
Z = zeros(length(L), length(unique(L)));
L = L(:,ones(length(unique(L)),1));
Z(L == T') = 1;
end