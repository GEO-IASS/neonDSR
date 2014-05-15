function [ specie_titles, reflectances, info ] = loadGroundCSVFile( fieldPath, smoothing_window_size )
%LOADGROUNDCSVFILE Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
 smoothing_window_size = 4;
end

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

specie_titles = file_columns{1,1,:}; % char(file_columns{1,1,:});
a = [file_columns(1, 2:numel(file_columns))]';
numerical_part_of_file=reshape(cell2mat(a), numel(file_columns{1}), numel(file_columns)-1); % one column containing textual info (specie name)
info = numerical_part_of_file(:, 1:9);
reflectances = numerical_part_of_file(:, 10:numel(file_columns) - 1);

%% pre-process data
%remove water absorbtion bands
%cut nans
reflectances(:,215:224) = []; %svm could not work with NaN, so we removed those columns instead of setting to NaN
reflectances(:,151:171) = [];
reflectances(:,105:120) = [];

%shuffle
random_permutations = randperm(size(reflectances,1));
reflectances = reflectances(random_permutations,:); % samples_reflectance is ordered by specie, shuffle it
specie_titles = specie_titles(random_permutations, :);

if smoothing_window_size > 0
  for i = 1 : size(reflectances,1)
    reflectances(i,:) = gaussian_smoothing(reflectances(i,:), smoothing_window_size);
  end
end

%plot nans and cut columns
%x_cut = size(cut_nans, 2); x = 1:224; figure; plot(x,smoothed); figure; plot(x,shuffled_samples_reflectance); plot(1:x_cut, cut_nans);


end

