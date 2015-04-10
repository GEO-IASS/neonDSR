
%% load field data
%envi = init();

init();

global setting;

addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/mesma'));


[ground_specie_titles, ground_reflectances] = extractPixels(envi, setting.FIELD_PATH);
% only remove water absorption bands for the ones we care about
ground_reflectances = removeWaterAbsorbtionBands(ground_reflectances, 0);

figure, plot(ground_reflectances(1,:));

%% Print ground data as comma separate  -> to be imported to the spectral library instead of cherry picker data

print_library(ground_specie_titles, ground_reflectances);  % copy lines to spectral_library file

%% load current spectral library and visualize it
% The result of the resampling method along with other manually extracted
% reflectances are stored in spectral_library.csv

[ species, reflectance ] = load_Spectral_library();

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
[indexes, abundances, errors] = run_MESMA_brute_small(reflectance, species, ground_reflectances, ground_specie_titles);
toc


%%
classes = cell(size(indexes, 1),1);
indexes(indexes==0)=1; % set to null

%classes = cell(25,1);

for i=1:size(indexes, 1)
    %indexes(i, :)
    classes(i) = {getPlant(indexes(i, :), species)};
end

[c, order] = confusionmat(ground_specie_titles, classes)


%% MESMA ViperTools Approach


