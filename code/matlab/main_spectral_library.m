

%% load current spectral library and visualize it
% The result of the resampling method along with other manually extracted
% reflectances are stored in spectral_library.csv

visualize = 0;

fileData = csvread('/cise/homes/msnia/zproject/neonDSR/docs/spectral_library.csv');
wavelength = str2double(fileData(1,11:size(fileData,2))) * 10^-3;
species = fileData(2:size(fileData,1),1);
reflectance = str2double(fileData(2:size(fileData,1),11:size(fileData,2)));
reflectance = removeWaterAbsorbtionBands( reflectance, 0);

for i=1:size(reflectance, 1)
    for j=1:size(reflectance, 2)
        if isnan(reflectance(i,j))
            reflectance(i,j) = (reflectance(i,j - 1) + reflectance(i,j + 1)) / 2;
        end
    end
end

if visualize
    reflectance_figure = figure;
    plotReflectanceWavelength(reflectance_figure, reflectance(1:38,:), wavelength, 's', 0 );
    legend(strrep(species(1:38), '_', '\_'), 'Location', 'EastOutside');
    
    
    reflectance_figure = figure;
    plotReflectanceWavelength(reflectance_figure, reflectance(39:size(reflectance,1),:), wavelength, 's', 0 );
    legend(strrep(species(39:size(reflectance,1)), '_', '\_'), 'Location', 'EastOutside');
end

%% load field data
envi = init();

global setting;
fieldPath = setting.FIELD_PATH;

smoothing_window_size = 4;
[ground_specie_titles, ground_reflectances] = extractPixels(envi, fieldPath);
% only remove water absorption bands for the ones we care about
ground_reflectances = removeWaterAbsorbtionBands(ground_reflectances, 0);
plot(ground_reflectances(1,:));

%% MESMA Brute-force

% there was some issue in \ operator used in MESMA_brute_small
% line 102     a(2:p,:)=Ep\(x-ct*ones(1,M));
% Error using \LAPACK loading error:dlopen: cannot load any more object with static TLS
% To resolve it in the directory that you start matlab from create a file
% startup.m with content "ones(10)*ones(10);"
% http://stackoverflow.com/questions/19268293/matlab-error-cannot-open-with-static-tls

% actual code by Rob Heylen
clear L;
x=rand(50,1);
L{1}=rand(50,5);
L{2}=rand(50,10);
L{3}=rand(50,15);
[idx, A, rec, minerr]=MESMA_brute_small (x,L);
plot(L{1});
clear L;

library_size = size(reflectance, 1);
bands =  size(reflectance, 2);
sublibrary_indexes = combntns(1:library_size,3);
row_count = size(sublibrary_indexes,1);
%valid_sublibrary_indexes = ones(row_count,1) % remove reflectances of the
%same class from library
%for i=1:size(sublibrary_indexes,1)
%end

for i=1:size(sublibrary_indexes,1)
    triples_library{i} = zeros(bands, 3);
    triples_library{i}(:, 1) = reflectance(sublibrary_indexes(i, 1), :)';
    triples_library{i}(:, 2) = reflectance(sublibrary_indexes(i, 2), :)';
    triples_library{i}(:, 3) = reflectance(sublibrary_indexes(i, 3), :)';
end
plot(triples_library{1}(1, :));




%    triples_library{1} = zeros(177,1);
%    triples_library{2} = zeros(177,1);
%    triples_library{3} = zeros(177,1);
%    triples_library{1}(:) = reflectance(sublibrary_indexes(i, 1), :)';
%    triples_library{2}(:) = reflectance(sublibrary_indexes(i, 2), :)';
%    triples_library{3}(:) = reflectance(sublibrary_indexes(i, 3), :)';

%    x = ground_reflectances(1, :)';
%    L = triples_library;
%    [idx, A, rec, minerr]=MESMA_brute_small (x, L);

tic
L{1} = reflectance';
L{2} = reflectance';
L{3} = reflectance';

reflectance_figure = figure;
for i=1:size(ground_reflectances,1)
    x = ground_reflectances(i, :)';
    
    disp(['Time: ' datestr(now, 'HH:MM:SS')])
    [idx, A, rec, minerr]=MESMA_brute_small (x, L);
    disp(['Time: ' datestr(now, 'HH:MM:SS')])

    plot([reflectance(idx(1),:)' reflectance(idx(2),:)' reflectance(idx(3),:)' rec x], '-x');
   
    legend([strcat(species(idx(1)),': ', num2str(A(1),4)), ...
        strcat(species(idx(2)),': ', num2str(A(2),4)), ... 
        strcat(species(idx(3)),': ', num2str(A(3),4)), ... 
        'Recreated', strcat('Actual:::', ground_specie_titles(i))]);
    
    file = sprintf(strcat( int2str(i), '.','png'));
    
    saveas(reflectance_figure, file);
end
toc
%% MESMA ViperTools Approach

