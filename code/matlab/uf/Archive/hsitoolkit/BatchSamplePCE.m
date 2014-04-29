function Results = BatchSamplePCE(X)


% Results = BatchSamplePCE(X)

[Parameters] = PCE_Sample_Parameters_DifferentWay(X);
numE = [3 5 7];
beta = Parameters.beta;
scaleC = [1, 10];

for i = 1:length(numE)
    for j = 1:length(scaleC)
        [LogLikelihoodTrace, SampleTrace, ClusterResults] = PCE_Sample(X, Parameters);
        Parameters.MaxNumEMs = numE(i);
        Parameters.beta = beta*scaleC(j);
        
        Parameters.AlphaPropVector = ones(1, Parameters.MaxNumEMs);
        
        Parameters.P = [];
        for k = 1:max(Parameters.L)
            Parameters.P(:,:,k) = DirichletSample(Parameters.AlphaPropVector, size(X,1));
        end
        
        Parameters.E = [];
        for k = 1:max(Parameters.L)    
            locations = find(Parameters.L == k);
            if(length(locations) < Parameters.MaxNumEMs)
                Parameters.E(:,:,k) = X(locations,:);
                for j = length(locations)+1:Parameters.MaxNumEMs
                    keyboard; %this case has not yet been coded
                end
            else
                [Ae, ~, ~] = VCA(X(locations,:)','Endmembers', Parameters.MaxNumEMs);
                Parameters.E(:,:,k) = Ae';
                Parameters.EPriorMean(k,:) = mean(X(locations,:));
            end   
        end
              
        Results(i,j).L = LogLikelihoodTrace;
        Results(i,j).S = SampleTrace;
        Results(i,j).C = ClusterResults;
        Results(i,j).P = Parameters;
        save('TempResults', 'Results');
    end
end
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

