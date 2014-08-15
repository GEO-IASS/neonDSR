function  [indexes, abundances, errors] = run_MESMA_brute_small( reflectance_library, species_library, ground_reflectances, ground_specie_titles )
%RUN_MESMA_BRUTE_SMALL Summary of this function goes here
%   Detailed explanation goes here

L{1} = reflectance_library';
L{2} = reflectance_library';
L{3} = reflectance_library';

rows = size(ground_reflectances,1);
%rows = 55;

indexes = zeros(rows,3);
abundances = zeros(rows,3);
errors = zeros(rows, 1);

for i=1:rows
    reflectance_figure = figure;
    set(reflectance_figure, 'Visible', 'off');
    x = ground_reflectances(i, :)';
    
    disp(['Time: ' datestr(now, 'HH:MM:SS')])
    [idx, A, rec, minerr]=MESMA_brute_small (x, L);
    disp(['Time: ' datestr(now, 'HH:MM:SS')])
    
   
    abundances(i,:) = A;
    errors(i) = minerr;
    
    
    
    idx(idx==0)=1; % set to null
    
     indexes(i,:) = idx;
    
    plot([reflectance_library(idx(1),:)' reflectance_library(idx(2),:)' reflectance_library(idx(3),:)' rec x], '-x');
    
    legend([strcat(species_library(idx(1)),': ', num2str(A(1),4)), ...
        strcat(species_library(idx(2)),': ', num2str(A(2),4)), ...
        strcat(species_library(idx(3)),': ', num2str(A(3),4)), ...
        'Recreated', strcat('Actual:::', ground_specie_titles(i))]);
    
    file = sprintf(strcat( int2str(i), '.','png'));
    
    saveas(reflectance_figure, [pwd strcat('/images/', file)]);
    close(reflectance_figure);
end
end

