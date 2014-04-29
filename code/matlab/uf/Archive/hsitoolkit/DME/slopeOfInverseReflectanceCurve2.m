function [slopeOutput] = slopeOfInverseReflectanceCurve2(reflectanceValues, lookupStruct)

index = dsearchn(lookupStruct.reflectance, reflectanceValues);
index(index==1) = 2;
index(index==lookupStruct.numEl) = lookupStruct.numEl-1;
indexPlusOne = index + 1;
indexMinusOne = index - 1;
slopeOutput=(lookupStruct.albedo(indexPlusOne,1) - lookupStruct.albedo(indexMinusOne,1))./(lookupStruct.reflectance(indexPlusOne,1) - lookupStruct.reflectance(indexMinusOne,1));

end