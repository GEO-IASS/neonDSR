function [reflectanceOutput] = convertToReflectance2_noclip(albedoValues, lookupStruct)

Hmu = (1 + 2*lookupStruct.mu)./(1 + 2*lookupStruct.mu*sqrt(1-albedoValues));
Hmu0 = (1 + 2*lookupStruct.mu0)./(1 + 2*lookupStruct.mu0*sqrt(1-albedoValues));

R = albedoValues./(4*(lookupStruct.mu + lookupStruct.mu0));

reflectanceOutput = R.*Hmu.*Hmu0;
end
