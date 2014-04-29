function [parameters] = MacMicParametersBatchDEM()

load HYLIDSynthInitDEM
load HYLIDSynthWavelengths

parameters.M                    = 3;
parameters.vcaEndmembers        = 0;
parameters.mu                   = 0.00000001;
parameters.startingEndmembersL  = HYLIDSynthInitDEM.LinData;
parameters.startingEndmembersNL = HYLIDSynthInitDEM.NonLinData;
parameters.wavelengths          = HYLIDSynthWavelengths;
parameters.learningDivide       = 2;
parameters.EstimateEndmembers   = 0;
parameters.PASS                 = 1;
parameters.VERBOSE              = 1;
parameters.NoiseVals            = [0, 0.001];%[0, 0.00001, 0.0001]; %, 0.001, 0.01];
parameters.NumExperiments       = 1;



parameters.NumSamples = 5000;
parameters.Degrees    = 70*rand(1,1);
parameters.PGenShift  = 2;
parameters.PGenScale  = 8;

M                            = parameters.M;
parameters.DirParamsPOnly    = round(parameters.PGenShift+parameters.PGenScale*rand(1, M));
parameters.DirParamsFOnly    = round(parameters.PGenShift+parameters.PGenScale*rand(1, M));
LinPartDirParamsPMix         = round(parameters.PGenShift+rand(1, M));
NonLinPartDirParamsPMix      = round(sum(LinPartDirParamsPMix));
parameters.DirParamsPMix     = round(horzcat(LinPartDirParamsPMix, NonLinPartDirParamsPMix));
parameters.DirParamsFMix     = round(parameters.PGenShift+parameters.PGenScale*rand(1, M));