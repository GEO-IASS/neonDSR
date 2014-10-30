
tic
init();
global setting;
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/io'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/io/csvIO'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/svm'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/svm/libsvm'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/hyperspectral'));

[ species, reflectances, rois, northings, eastings, flights ] = get_field_ATCOR_pixels();


% shuffle pixels
rng(setting.RANDOM_VALUE_SEED);
permutation_idx = randperm(numel(species));
species = species(permutation_idx);
rois = rois(permutation_idx);
reflectances = reflectances(permutation_idx, :);

% scale each feature separately
% data = reflectances; % scaled_reflectances_01_featurebased
% minimums = min(data, [], 1);
% ranges = max(data, [], 1) - minimums;
% data = (data - repmat(minimums, size(data, 1), 1)) ./ repmat(ranges, size(data, 1), 1);
% %test_data = (test_data - repmat(minimums, size(test_data, 1), 1)) ./ repmat(ranges, size(test_data, 1), 1);
% figure, plot(data(1,:)');

% scale reflectance intensity values to [0,1]
scaled_reflectances_01_global = reflectances;
for i=1: size(scaled_reflectances_01_global, 1)
    scaled_reflectances_01_global(i,:) = scalePixel(scaled_reflectances_01_global(i,:));
end

ndvi = toNDVI(scaled_reflectances_01_global);
green_ndvi_reflectances = scaled_reflectances_01_global;
for i=1:numel(ndvi)
    if ndvi(i) < setting.NDVI_THRESHOLD
        green_ndvi_reflectances(i, :)  = nan;
    end
    
    if green_ndvi_reflectances(i,setting.NIR_INDEX) < setting.NIR_THRESHOLD
        green_ndvi_reflectances(i, :)  = nan;
    end
end
low_ndvi_indexes = ~any(~isnan(green_ndvi_reflectances), 2);

green_ndvi_species = species;
green_ndvi_rois = rois;
green_ndvi_reflectances(low_ndvi_indexes,:)=[]; % from 1269 to 712
green_ndvi_species(low_ndvi_indexes) = [];    %TODO grid search for parameters
green_ndvi_rois(low_ndvi_indexes) = [];



nongreen_ndvi_reflectances = scaled_reflectances_01_global;
nongreen_ndvi_reflectances(~low_ndvi_indexes,:)=[];

toc

%% Display signals

visualize_reflectances(nongreen_ndvi_reflectances);
visualize_reflectances(green_ndvi_reflectances);


%%
[svm_gaussian_atcor, svm_poly_atcor, svm_rbf_atcor] = get_libsvm_statistics_canopy_based(green_ndvi_species, green_ndvi_reflectances, green_ndvi_rois);

figure;
plot(setting.SVM_GAUSSIAN_SMOOTHING_WINDOWS, svm_gaussian_atcor);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');
title(sprintf('Effects of Gaussian Window Size on Classification Accuracy \n (canopy-based) - Polynimial Kernel Order 3'));

figure;
%semilogx(polynomial_orders(1:numel(polynomial_orders)), svm_results_poly(1:numel(polynomial_orders)),'marker', 's');
plot(setting.SVM_POLYNOMIAL_ORDERS, svm_poly_atcor);
xlabel('SVM Kernel - polynomial degree'); ylabel('Accuracy (%)');
title(sprintf('Effects of Polynomial Order on Classification Accuracy (canopy-based)'));

figure;
semilogx(setting.SVM_RBF_SIGMA_VALUES, svm_rbf_atcor);
grid on
xlabel('SVM Kernel - RBF (\sigma)'); ylabel('Accuracy (%)');
title('Effects of RBF Kernel \sigma on SVM Classification Accuracy (canopy-based)');

%% FLAASH
% best performance confusion matrix


[ species, reflectances, rois, northings, eastings, flights ] = get_field_FLAASH_pixels(envi03, envi04, envi05);
[svm_gaussian_flaash, svm_poly_flaash, svm_rbf_flaash] = get_svm_statistics_canopy_based(species, reflectances, rois);


%%

% the final result of cross-validation would be trained on all the data
% using the parameters that had the best accuracy in average of its k-fold
% runs.