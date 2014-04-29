function [albedoOutput] = lookupAlbedo2(reflectanceValues, lookupStruct)

index = dsearchn(lookupStruct.reflectance, reflectanceValues);
albedoOutput = lookupStruct.albedo(index,1);


end