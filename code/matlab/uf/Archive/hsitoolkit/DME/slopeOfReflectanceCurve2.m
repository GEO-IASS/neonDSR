function [slopeOutput] = slopeOfReflectanceCurve2(albedoValues, lookupStruct)

index = dsearchn(lookupStruct.albedo, albedoValues);
index(index==1) = 2;
index(index==lookupStruct.numEl) = lookupStruct.numEl-1;
indexPlusOne = index + 1;
indexMinusOne = index - 1;
slopeOutput=(lookupStruct.reflectance(indexPlusOne,1) - lookupStruct.reflectance(indexMinusOne,1))./(lookupStruct.albedo(indexPlusOne,1) - lookupStruct.albedo(indexMinusOne,1));
slopeOutput(slopeOutput == 0) = 60.134887726943454;

end