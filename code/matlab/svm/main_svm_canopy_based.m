
tic
init(); 
global setting;
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/io'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/io/csvIO'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/svm'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/hyperspectral'));

[ species, reflectances, rois, northings, eastings, flights ] = get_field_ATCOR_pixels();

% scale reflectance intensity values to [0,1]
for i=1: size(reflectances, 1)
    reflectances(i,:) = scalePixel(reflectances(i,:));
end


ndvi = toNDVI(reflectances);
cleared_ndvi_reflectances = reflectances;
for i=1:numel(ndvi)
        if ndvi(i) < setting.NDVI_THRESHOLD
            cleared_ndvi_reflectances(i, :)  = nan;
        end
        
        if cleared_ndvi_reflectances(i,setting.NIR_INDEX) < setting.NIR_THRESHOLD
            cleared_ndvi_reflectances(i, :)  = nan;
        end
    
end         
low_ndvi_indexes = ~any(~isnan(cleared_ndvi_reflectances), 2);

cleared_ndvi_species = species;
cleared_ndvi_rois = rois;
cleared_ndvi_reflectances(low_ndvi_indexes,:)=[]; % from 1269 to 712
cleared_ndvi_species(low_ndvi_indexes) = [];    %TODO grid search for parameters 
cleared_ndvi_rois(low_ndvi_indexes) = [];



valid_ndvi_reflectances = reflectances;
valid_ndvi_reflectances(~low_ndvi_indexes,:)=[];

toc

%% Display signals

visualize_reflectances(cleared_ndvi_reflectances);
visualize_reflectances(valid_ndvi_reflectances);


%%
[svm_gaussian_atcor, svm_poly_atcor, svm_rbf_atcor] = get_svm_statistics_canopy_based(cleared_ndvi_species, cleared_ndvi_reflectances, cleared_ndvi_rois);

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
