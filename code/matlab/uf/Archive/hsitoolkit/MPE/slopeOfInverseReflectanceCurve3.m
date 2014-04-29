function [slopeOutput] = slopeOfInverseReflectanceCurve3(reflectanceValues, lookupStruct)

albedos     = lookupAlbedo3(reflectanceValues, lookupStruct);
slopeOutput = 1./(slopeofReflectanceCurve2(albedos,lookupStruct));

end