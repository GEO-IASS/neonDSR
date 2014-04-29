function [ExperimentStruct, ErrorTypes] = MacMicDEMBatch(parameters)

%[ExperimentStruct, ErrorTypes] = MacMicDEMBatch(parameters)

addpath('/qpc');
M                        = parameters.M;
Ns                       = parameters.NumSamples;
NumNoiseVals             = length(parameters.NoiseVals);
parameters
%INITIALIZE STRUCTURE TO STORE EXPERIMENTAL RESULTS
ExperimentStruct.parameters  = parameters;
ExperimentStruct.RSS         = zeros(NumNoiseVals, parameters.NumExperiments, 1);
ExperimentStruct.Errors      = zeros(NumNoiseVals, 2*parameters.NumExperiments, 5);
ExperimentStruct.DirPar      = cell(NumNoiseVals, parameters.NumExperiments, 4);
ExperimentStruct.ErrorLabels = {'errorLO', 'errorNLO','errorFPO', 'errorLM', 'errorFM'};
ExperimentStruct.DegNLError  = zeros(NumNoiseVals, parameters.NumExperiments, Ns, 3);

for n = 1:NumNoiseVals
    ErrorIndex = 1;
    for ExpNum = 1:parameters.NumExperiments
        
        %GENERATE WITH DIRICHLET PARAMETERS
        parameters.DirParamsPOnly    = parameters.PGenShift+parameters.PGenScale*rand(1, M);
        parameters.DirParamsFOnly    = parameters.PGenShift+parameters.PGenScale*rand(1, M);
        LinPartDirParamsPMix         = parameters.PGenShift+rand(1, M);
        NonLinPartDirParamsPMix      = sum(LinPartDirParamsPMix);
        parameters.DirParamsPMix     = horzcat(LinPartDirParamsPMix, NonLinPartDirParamsPMix);
        parameters.DirParamsFMix     = parameters.PGenShift+parameters.PGenScale*rand(1, M);
        
        ExperimentStruct.DirPar{ExpNum, 1} = parameters.DirParamsPOnly;
        ExperimentStruct.DirPar{ExpNum, 2} = parameters.DirParamsFOnly;
        ExperimentStruct.DirPar{ExpNum, 3} = parameters.DirParamsPMix;
        ExperimentStruct.DirPar{ExpNum, 4} = parameters.DirParamsFMix;
        
        %GENERATE DATA AND UNMIX
        [SynthData,PPO,FPO,PPM,FPM] = MakeMicroMixedData(parameters, parameters.NoiseVals(n));
        Noise                       = parameters.NoiseVals(n)*randn(size(SynthData)); %TRUNCATED GAUSSIAN
        SynthData2                  = SynthData + Noise;
        SynthData2                  = min(1, max(0, SynthData2));
        
        FirstPart                   = vertcat(PPO, zeros(1, Ns));
        LastPart                    = vertcat(zeros(M, Ns), ones(1, Ns));
        AllP                        = horzcat(FirstPart, PPM, LastPart);
        
        %NEXT MAKE THIS MORE GENERAL SO WE RUN MULTIPLE EXPERIMENTS PER DATA
        %SET ALSO.
        parameters.InitMeth.InitF      = [];
        parameters.InitMeth.InitP      = [];
        parameters.InitMeth.InitPFirst = 0;
        
        [P, F, ~, Error, ~] = MacMicUnmixDEM(SynthData2, parameters, 35);
        
        fprintf('For Experiment Number %d The RSS error is... %f\n', ExpNum, Error);
        
        %STORE RSS
        ExperimentStruct.RSS(n, ExpNum) = Error;
        
        %COMPUTE ALL ERRORS IN PROPORTIONS (MAY CHANGE TO EUCLID)
        ErrorTypes = cell(4,1);
        ErrorTypes{1} = abs(P(1:M, 1:parameters.NumSamples)-PPO);
        ErrorTypes{2} = [P(1:M, 2*Ns+1:3*Ns);abs(1-P(M+1, 2*Ns+1:3*Ns))];
        ErrorTypes{3} = FPO-F(:, 2*Ns+1:3*Ns);
        ErrorTypes{4} = PPM-P(:, Ns+1:2*Ns);
        ErrorTypes{5} = FPM-F(:, Ns+1:2*Ns);
        
        figure; imagesc(P)
        
        
        TrueNLProps   = P(M+1, Ns+1:2*Ns);
        EstNLProps    = PPM(M+1, :);
        NLErr         = TrueNLProps - EstNLProps;
        ExperimentStruct.DegNLError(n,ExpNum, : , 1) = TrueNLProps;
        ExperimentStruct.DegNLError(n,ExpNum, : , 2) = EstNLProps;
        ExperimentStruct.DegNLError(n,ExpNum, : , 3) = NLErr;
        %STORE STATISTICS OF ERROR DISTRIBUTIONS
        for ErrorTypeInd = 1:5
            ErrorVals                                             = abs(ErrorTypes{ErrorTypeInd});
            ExperimentStruct.Errors(n, ErrorIndex,   ErrorTypeInd)   = max( ErrorVals(:));
            ExperimentStruct.Errors(n, ErrorIndex+1, ErrorTypeInd)   = mean(ErrorVals(:));
        end
        
        ErrorIndex = ErrorIndex+2;
        save ExperimentStruct ExperimentStruct
        
        %MAY WANT TO MOVE THIS INTO MacMicUnmix SO I CAN VIEW AS A FUNCTION OF
        %ITERATION
        
        figure;
        subplot(311);
        ET = ErrorTypes{4};
        hist(ET(:), -1:0.001:1);title(sprintf('Errors PPM Experiment %d', ExpNum))
        subplot(312);
        ET = ErrorTypes{5};
        hist(ET(:), -1:0.001:1);title(sprintf('Errors FPM Experiment %d', ExpNum))
        subplot(313)
        hist(NLErr, -1:0.001:1);title(sprintf('Errors in Nonlinear Proportion pM+1 Experiment %d', ExpNum));
        figure;
        FPMErrors = abs(ErrorTypes{5})';
        FPMErrors = FPMErrors.*FPMErrors;
        FPMErrors = sqrt(mean(FPMErrors, 2));
        scatter(abs(NLErr), abs(FPMErrors)); title('Errors in Albedo Proportions vs NL Proportion')
        xlim([0,1]);ylim([0,1])
    end
end

if 0
    figure; plot(ExperimentStruct.RSS); title('RSS for each experiment');
    figure; plot(ExperimentStruct.Errors(1:2:end, 4));
    hold on
    plot(ExperimentStruct.Errors(2:2:end, 4), 'r')
    title(ExperimentStruct.ErrorLabels{4})
    hold off
    figure;plot(ExperimentStruct.Errors(1:2:end, 5));
    hold on
    plot(ExperimentStruct.Errors(2:2:end, 5), 'r')
    title(ExperimentStruct.ErrorLabels{5})
    hold off
end

