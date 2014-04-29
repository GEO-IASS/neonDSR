function [Results] = BatchPCE_Sample(InputData);

[Parameters] = PCE_Sample_Parameters(InputData);
%k = [.5, 1, 2, 5]; %InnovationBatch1 Parameters.Innovation = Parameters.NumESamples./(k(i)*size(InputData,1)) values
k = [1, 10, 100]; %InnovationBatch2 Parameters.Innovation = Parameters.NumESamples./(k(i)*size(InputData,1)) values

for i = 1:length(k)
    Parameters.Innovation = Parameters.NumESamples./(k(i)*size(InputData,1));
    for j = 1:5
        [LogLikelihoodTrace, SampleTrace, ClusterResults] = PCE_Sample(InputData, Parameters);
        Results(i,j).LogLikelihoodTrace = LogLikelihoodTrace;
        Results(i,j).SampleTrace = SampleTrace;
        Results(i,j).ClusterResults = ClusterResults;
        Results(i,j).Parameters = Parameters;
    end
end