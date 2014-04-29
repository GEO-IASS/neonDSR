function [reflectanceOutput] = convertToReflectance2(albedoValues, lookupStruct)

Hmu = lookupStruct.Hmu./(1 + 2*lookupStruct.mu*sqrt(1-albedoValues));
Hmu0 = lookupStruct.Hmu0./(1 + 2*lookupStruct.mu0*sqrt(1-albedoValues));

R = albedoValues./lookupStruct.denom;

reflectanceOutput = R.*Hmu.*Hmu0;
reflectanceOutput(reflectanceOutput > 1) = 1;
end