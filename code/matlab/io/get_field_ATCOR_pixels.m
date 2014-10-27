function [ specie, reflectance, roi, northing, easting, flight ] = get_field_ATCOR_pixels()
% load field data csv file and return items. Data given by Sarah Graves are
% in ATCOR atmospheric correction.
global setting;

field_trips = csv_read(setting.FIELD_PATH);

specie = field_trips(:,5);
specie(1,:) = [];

reflectance = field_trips(:,13:236);
reflectance(1,:) = [];
reflectance = str2double(reflectance);

roi = field_trips(:,3);
roi(1,:) = [];
roi = str2double(roi);

northing = field_trips(:,10);
northing(1,:) = [];
northing = str2double(northing);

easting = field_trips(:,9);
easting(1,:) = [];
easting = str2double(easting);

flight = field_trips(:,2);
flight(1,:) = [];

end

