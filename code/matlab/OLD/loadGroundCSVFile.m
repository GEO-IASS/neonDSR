function [ specie_titles, reflectances, info ] = loadGroundCSVFile( fieldPath)
%% info: {'Specie','Specie_ID','ROI_ID','ID','X','Y','MapX','MapY','Lat','Lon'}
% THIS IS KINDA OBSOLETE IS FOR PREVIOUS FIELD TRIPS SAVED IN SAPARATE
% FOLDERS. THE NEW ONE IS ONE CSV FILE FOR ALL TRIPS;
% best  smoothing_window_size = 4;


fileID = fopen(fieldPath);
% file_columns is an array of cells each of which is an array of items
file_columns = textscan(fileID, ['%s %f %f %f %f %f %f %f %f %f' ... % {'Specie','Specie_ID','ROI_ID','ID','X','Y','MapX','MapY','Lat','Lon'}
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %20
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %40
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %60
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %80
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %100
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %120
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %140
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %160
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %180
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %200
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %220
    '%f %f %f %f' %224   ---  224 wavelengths
    ], ...
    'delimiter',',','EmptyValue',-Inf, 'headerLines', 1);
fclose(fileID);

%% separate columns
specie_titles = file_columns{1,1,:}; % char(file_columns{1,1,:});
a = [file_columns(1, 2:numel(file_columns))]';
numerical_part_of_file=reshape(cell2mat(a), numel(file_columns{1}), numel(file_columns)-1); % one column containing textual info (specie name)
info = numerical_part_of_file(:, 1:9);
reflectances = numerical_part_of_file(:, 10:numel(file_columns) - 1);

% x = 1:size(reflectances,2); figure; plot(x,reflectances);

end

