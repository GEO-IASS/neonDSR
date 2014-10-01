function [ specie, reflectance ] = get_field_pixels(  )
% load field data csv file and return items.
global setting;

field_trips = csv_read(setting.FIELD_PATH);
specie = field_trips(:,5);
specie(1,:) = [];
reflectance = field_trips(:,13:236);
reflectance(1,:) = [];

roi = field_trips(:,3);

end

