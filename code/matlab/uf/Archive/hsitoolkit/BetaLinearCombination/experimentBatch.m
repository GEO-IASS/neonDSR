[genParameters] = generateSimulatedDataParameters(BP);
[uParameters] = unmixBetaParameters(BP);


nn = [0.001, 0.005, 0.01, 0.05];
%nn = 0.001;
numRep = 5;


for i = 1:length(nn)
    disp('$$$$$');
    i
    for j = 1:numRep
        j
        genParameters.noiseScale = nn(i);
        [X, Ptrue] = generateSimulatedData(genParameters);
        [P] = unmixBeta(X, uParameters);
        err(i,j) = sum(sum((P - Ptrue).*(P - Ptrue)));
    end
end