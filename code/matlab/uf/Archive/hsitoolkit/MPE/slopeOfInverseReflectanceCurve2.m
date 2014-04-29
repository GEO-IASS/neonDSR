function [slopeOutput] = slopeOfInverseReflectanceCurve2(reflectanceValues, lookupStruct)

albedos     = lookupAlbedo3(reflectanceValues, lookupStruct);
slopeOutput = 1./(slopeOfReflectanceCurve2(albedos,lookupStruct));

end