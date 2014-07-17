
%% load field data
envi = init();

global setting;
fieldPath = setting.FIELD_PATH;

[ground_specie_titles, ground_reflectances] = extractPixels(envi, fieldPath);
% only remove water absorption bands for the ones we care about
ground_reflectances = removeWaterAbsorbtionBands(ground_reflectances, 0);
plot(ground_reflectances(1,:));

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

%% MESMA Brute-force

% there was some issue in \ operator used in MESMA_brute_small
% line 102     a(2:p,:)=Ep\(x-ct*ones(1,M));
% Error using \LAPACK loading error:dlopen: cannot load any more object with static TLS
% To resolve it in the directory that you start matlab from create a file
% startup.m with content "ones(10)*ones(10);"
% http://stackoverflow.com/questions/19268293/matlab-error-cannot-open-with-static-tls

% actual code by Rob Heylen
%clear L;
%x=rand(50,1);
%L{1}=rand(50,5);
%L{2}=rand(50,10);
%L{3}=rand(50,15);
%[idx, A, rec, minerr]=MESMA_brute_small (x,L);
%plot(L{1});
%clear L;

%library_size = size(reflectance, 1);
%bands =  size(reflectance, 2);
%sublibrary_indexes = combntns(1:library_size,3);
%row_count = size(sublibrary_indexes,1);

tic
run_MESMA_brute_small(reflectance, species, ground_reflectances, ground_specie_titles);
toc
%% MESMA ViperTools Approach

