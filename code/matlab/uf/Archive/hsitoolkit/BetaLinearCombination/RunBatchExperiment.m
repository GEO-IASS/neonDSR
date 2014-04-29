function [KLDivergences, P, Q] = RunBatchExperiment

Parameters = betaCombCodeParameters();
Parameters.display = 0;
NumRepeats = 10;

%alphaParameters = [.1, 1; .1 10; .1 100];%
%alphaParameters = [1, 10; 2, 5; 10, 100 ];
%alphaParameters = [.1, 1; 10, 1; 100, 1 ];%
alphaParameters = [0.1, 1, 1, 0.1;  10, 1, 1, 10; 1, 10, 10, 1;  0.1, 1, 0.1, 1;  2, 5, 2, 5;  1, 10, 1, 10]; 

for i = 1:size(alphaParameters,1);
    for j = 1:NumRepeats;
        Parameters.betaA = alphaParameters(i,[1, 3]);
        Parameters.betaB = alphaParameters(i,[2, 4]);
        %Parameters.alpha = alphaParameters(i,:);
        [KLDiv, p, q] = betaCombCode(Parameters);
        KLDivergences(i,j) = KLDiv;
        P(i,j,:) = p;
        Q(i,j,:) = q;
    end
end
        

