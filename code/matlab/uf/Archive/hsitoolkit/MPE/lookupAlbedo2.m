function [albedoOutput] = lookupAlbedo2(reflectanceValues, lookupStruct)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRE-COMPUTE CONSTANTS THAT ARE INDEPENDENT OF REF AND ALBEDO %%%
%%% THESE CONSTANTS ONLY NEED TO BE EVALUATED ONE TIME FOR FIXED %%%
%%% thetai AND thetae                                            %%%
s           = lookupStruct.mu0+lookupStruct.mu;
t           = (4*s)/((1+2*lookupStruct.mu0)*(1+2*lookupStruct.mu));
almosta     = 4*lookupStruct.mu0*lookupStruct.mu*t;
almostb     = 2*s*t; %b without r divided by 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% THESE QUANTITIES DEPEND ON REFLECTANCE AND HAVE TO BE RECOMPUTED %%%
a = reflectanceValues*almosta+1;
b = reflectanceValues*almostb;
c = reflectanceValues*t-1;
x = (-b+sqrt(b.*b-4.*a.*c))./(2*a);
albedoOutput = 1-x.*x;
end