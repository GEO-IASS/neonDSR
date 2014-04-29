function [ parameters ] = MacMicUnmixParametersDEM()
%function [ parameters ] = MacMicUnmixParameters()

%PARAMETER INITIALIZATION FOR MacMicUnmix;
parameters.M                    = 3;     %Number of Endmembers
parameters.vcaEndmembers        = 1;     %1 if you want VCA to initialize the endmembers, 0 else
parameters.VCA_ITER				= 10;
parameters.mu                   = 0.00001; %Same as SPICE mu
parameters.startingEndmembersL  = [];    %Starting endmembers if you don't want to use VCA:CHANGE!!
parameters.startingEndmembersNL = [];    %Starting endmembers if you don't want to use VCA:CHANGE!!
parameters.wavelengths          = [];
parameters.learningDivide       = 2;     %factor to reduce learning rate
parameters.EstimateEndmembers   = 0;     % If 1, estimate endmembers, otherwise do not estimate endmembers
parameters.PASS                 = 1;     %pass =0; If pass == 1, stop updating endmembers if error increases
parameters.VERBOSE              = 1;     % If 1, print information on updates and display new vs old endmembers.
parameters.InitMeth.InitF       = [];
parameters.InitMeth.InitP       = [];
parameters.InitMeth.InitPFirst  = 0;
end
