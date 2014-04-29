function [slopeOutput] = SlopeRInverse(Albedos, ConvStruct)
%This is the entire function:
%
%function [slopeOutput] = SlopeRInverse(Albedos, ConvStruct)
%slopeOutput = 1./(slopeOfReflectanceCurve2(Albedos,ConvStruct));
%end

slopeOutput = 1./(slopeOfReflectanceCurve2(Albedos,ConvStruct));
end