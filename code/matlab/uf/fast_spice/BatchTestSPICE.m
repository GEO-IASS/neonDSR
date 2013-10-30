function Error = BatchTestSPICE()

NumRepeats = 50;

[parameters] = SPICEParameters();
Etrue = [1 1; 2 1; 1 2];

for i = 1:NumRepeats
    disp(num2str(i));
    
    parameters.reweightTermsPercentage = 0.05;
    [X, Ptrue] = generateData(Etrue, 1000);
    X = X + randn(size(X))*.01;
    [Eest, Pest] = SPICE(X', parameters);
    Error(i, 1) = computeError(Etrue, Eest);
    
    
    parameters.reweightTermsPercentage = -1;
    [Eest, Pest] = SPICE(X', parameters);
    Error(i, 2) = computeError(Etrue, Eest);
    
end