function [Albedos] = lookupAlbedo3(reflectanceValues, convStruct);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% THESE QUANTITIES DEPEND ON REFLECTANCE AND HAVE TO BE RECOMPUTED %%%
a       = reflectanceValues * convStruct.almosta + 1;
b       = reflectanceValues * convStruct.almostb;
c       = reflectanceValues * convStruct.t-1;
x       = (-b+sqrt(b.*b-4.*a.*c))./(2*a);
Albedos = 1-x.*x;

end