function [SynthData, PPropsOnly,FPropsOnly,PPropsMix, FPropsMix ] = MakeMicroMixedData(parameters, NoiseVal)
%function [SynthData, PPropsOnly,FPropsOnly,PPropsMix, FPropsMix ] = MakeMicroMixedData(parameters)
%
%parameters are the parameters using by MacMicUnmixDEM as well as the
%following:
% Typical Values - 
% MakeMicParams.DirParamsPOnly = [2 8 2]
% MakeMicParams.DirParamsFOnly = [2 8 2]
% MakeMicParams.DirParamsPMix  = [2 2 2 2]
% MakeMicParams.DirParamsFMix  = [2 8 2]
% MakeMicParams.NumSamples     = 5000;
% MakeMicParams.Degrees        = 70;
%
%This function creates a data set with three subsets, one purely macroscopic,
%one mixed macroscopic and microscopic, and the other purely microscopic.
%
%There are NumSamples samples in each subset (so 3*NumSamples total)
%The Degrees are the incidence and emittance angles used in Hapke's model
%The DirParams variables are parameters to be used for sampling proportions
%from Dirichlet Distributions.
%
%DirParamsPOnly generates proportions for the Purely Macroscopic Part.
%There are M of these
%
%DirParamsFOnly generates proportions for the Purely Microscopic Part.
%There are M of these
%
%DirParamsPMix  generates proportions for the mixture of Macro and Micro.
%There are M+1  of these (M for macro and 1 for micro)
%
%DirParamsFMix  generates proportions for the Micro part of the mixture of
%Macro and Micro.  There are M of these.


NUMCOMBOS     = 3; %Pure Linear, Mix of Linear and  Nonlinear, Pure Nonlinear
NumSamples    = 5000;%parameters.NumSamples;
LinearEndmems = parameters.startingEndmembersL;
AlbedoEndmems = parameters.startingEndmembersNL;
NumBands      = size(LinearEndmems, 1);
SynthData     = zeros(NumBands, NUMCOMBOS*NumSamples);
PPropsOnly    = DirichletSample(NumSamples, parameters.DirParamsPOnly)'; %FOR LINEAR MIX ONLY
FPropsOnly    = DirichletSample(NumSamples, parameters.DirParamsFOnly)'; %FOR NONLINEAR MIX ONLY
PPropsMix     = DirichletSample(NumSamples, parameters.DirParamsPMix)';  %FORLINEAR AND NONLINEAR JOINT
FPropsMix     = DirichletSample(NumSamples, parameters.DirParamsFMix)';  %FORLINEAR AND NONLINEAR JOINT

%CREATE ALBEDO & REFLECTANCE CONVERSION PARAMETERS AND STRUCTURE
angleEmergence     = -parameters.Degrees;%0;
angleIncidence     =  parameters.Degrees;%0;
mu                 = cosd(angleEmergence);
mu0                = cosd(angleIncidence);
s                  = mu0+mu;
t                  = (4*s)/((1+2*mu0)*(1+2*mu));
almosta            = 4*mu0*mu*t;
almostb            = 2*s*t; %b without r divided by 2
convStruct.s       = s;
convStruct.t       = t;
convStruct.almosta = almosta;
convStruct.almostb = almostb;
convStruct.mu      = mu;
convStruct.mu0     = mu0;

%CREATE DATA THAT IS ONLY LINEARLY MIXED
SynthData(:, 1:NumSamples) = LinearEndmems*PPropsOnly;

%COMPUTE AVERAGE ALBEDOS AND THEN CONVERT BACK TO REFLECTANCE TO CREATE DATA THAT
%IS ONLY NONLINEARLY MIXED
Albedos           = lookupAlbedo3(AlbedoEndmems, convStruct);
AveAlbedos        = Albedos*FPropsOnly;
Noise             = NoiseVal*randn(size(AveAlbedos)); %TRUNCATED GAUSSIAN
AveAlbedos        = AveAlbedos + Noise; %FOR EFFICIENCY, THE DATA ARE ONLY CLIPPED AT THE END
s                 = 2*NumSamples+1;
e                 = 3*NumSamples;
SynthData(:, s:e) = convertToReflectance2(AveAlbedos, convStruct);

%CREATE DATA THAT IS LINEARLY AND NONLINEARLY MIXED
AveAlbedos        = Albedos*FPropsMix;
Noise             = NoiseVal*min(1, max(0, randn(size(AveAlbedos)))); %TRUNCATED GAUSSIAN
AveAlbedos        = AveAlbedos + Noise;
TrueNonLinEndmems = convertToReflectance2(AveAlbedos, convStruct);

save TrueNonLinEndmems TrueNonLinEndmems
for kkk = 1:NumSamples;
    EwithMicro                   = horzcat(LinearEndmems, TrueNonLinEndmems(:, kkk));
    SynthData(:, NumSamples+kkk) = EwithMicro*PPropsMix(:, kkk);
end
Noise     = NoiseVal*randn(size(SynthData)); %TRUNCATED GAUSSIAN
SynthData = SynthData + Noise;
SynthData = min(1, max(0, SynthData)); %TRUNCATE DATA + NOISE TO [0,1] ONLY HERE

SynthData = SynthData';