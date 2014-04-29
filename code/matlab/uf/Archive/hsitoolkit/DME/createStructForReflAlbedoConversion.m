function [conversionStruct] = createStructForReflAlbedoConversion( angleIncidence, angleEmergence)

mu = cosd(angleEmergence);
mu0 = cosd(angleIncidence);
Hmu = 1 + 2*mu;
Hmu0 = 1 + 2*mu0;
denom = (4*(mu + mu0));

conversionStruct.mu = mu;
conversionStruct.mu0 = mu0;

conversionStruct.Hmu = Hmu;
conversionStruct.Hmu0 = Hmu0;
conversionStruct.denom = denom;

% albedo = 0:.0001:1;
albedo = 0:.0001:.65;
albedo = [albedo, .650001:.00005:.9];
albedo = [albedo, .9000001:.00001:.9999];
conversionStruct.numEl = numel(albedo);
Hmu = Hmu./(1 + 2*mu*sqrt(1-albedo));
Hmu0 = Hmu0./(1 + 2*mu0*sqrt(1-albedo));

R = albedo./denom;

conversionStruct.reflectance = (R.*Hmu.*Hmu0)';
conversionStruct.reflectance(conversionStruct.reflectance > 1) = 1;
conversionStruct.albedo = albedo';
end