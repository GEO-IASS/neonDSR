function  print_library( ground_specie_titles, ground_reflectances )
%PRINT_LIBRARY Summary of this function goes here
%   Detailed explanation goes here

fprintf('\n');
num_bands = size(ground_reflectances,2);

specie_list = sort(unique(ground_specie_titles));

for i=1:size(specie_list)
    specie = specie_list{i,1};
    
    indexes = strcmp(ground_specie_titles, specie);
    signals = ground_reflectances(indexes, :);
    signals_average = mean(signals);
  %  figure, plot(signals_average(:));
    fprintf('%s', specie);
    fprintf('%s', ',');
    fprintf('%d', i+3); % reserve the three first items for NULL. ROAD. SHADDOW
    fprintf('%s', ',0,0,0,0,0,0,0,0,');
    for i=1:num_bands
        fprintf('%s', num2str( signals_average(i),9));
        if i ~= num_bands
           fprintf('%s', ',');
        end
    end
    fprintf(1, '\n');
end

