function [parameters] = MacMicParametersDEM()

load HYLIDSynthInitDEM
load HYLIDSynthWavelengths

parameters.M                    = 3;
parameters.vcaEndmembers        = 0;
parameters.VCA_ITER				= 10;
parameters.mu                   = 0.00000001;
parameters.startingEndmembersL  = HYLIDSynthInitDEM.LinData;
parameters.startingEndmembersNL = HYLIDSynthInitDEM.NonLinData;
parameters.wavelengths          = HYLIDSynthWavelengths;
parameters.learningDivide       = 2;
parameters.EstimateEndmembers   = 0;
parameters.PASS                 = 1;
parameters.VERBOSE              = 1;
parameters.NoiseVals            = [0, 0.00001, 0.0001]; %, 0.001, 0.01];
parameters.NumExperiments       = 1;

        parameters.InitMeth.InitF      = [];
        parameters.InitMeth.InitP      = [];
        parameters.InitMeth.InitPFirst = 0;


parameters.NumSamples = 5000;
parameters.Degrees    = 70*rand(1,1);
parameters.PGenShift  = 2;
parameters.PGenScale  = 8;
