function [parameters] = MacMicParametersDEM()


load EndmembersCrater
parameters.M                    = 3;
parameters.vcaEndmembers        = 0;
parameters.startingEndmembersL  = EndmembersCrater;
parameters.startingEndmembersNL = EndmembersCrater;
parameters.mu                   = 0.00000001;
parameters.learningDivide       = 2;
parameters.EstimateEndmembers   = 0;
parameters.PASS                 = 1;
parameters.VERBOSE              = 1;
parameters.InitMeth.InitPFirst  = 0;
parameters.InitMeth.InitP       = [];
parameters.InitMeth.InitF       = [];
parameters.Degrees              = 10;