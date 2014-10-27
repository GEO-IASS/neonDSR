
init();
global setting;
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/io'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/io/csvIO'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/svm'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/hyperspectral'));

[ species, reflectances, rois, northings, eastings, flights ] = get_field_ATCOR_pixels();

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
    
end          %   @TODO
cleared_ndvi_reflectances(isnan(cleared_ndvi_reflectances,:), :) = [];

%% Display signals
% scale reflectance intensity values to [0,1]


figure, plot(setting.wavelength, reflectances'); title('Field Data - Original Form');
set(gca,'XTick', 400:200:2500); xlabel('Wavelength (nm)'), ylabel('Reflectance');

reflectances_rwab1 = removeWaterAbsorbtionBands(reflectances,1);
figure, plot(setting.wavelength, reflectances_rwab1'); title('Field Data - Removed Water Absorption Bands');
set(gca,'XTick', 400:200:2500); xlabel('Wavelength (nm)'), ylabel('Reflectance');

reflectances_rwab0 = removeWaterAbsorbtionBands(reflectances,0);
chopped_wavelength =  removeWaterAbsorbtionBands(setting.wavelength,0);
figure, plot(chopped_wavelength, reflectances_rwab0'); title('Field Data - Truncated Water Absorption Bands');
set(gca,'XTick', 400:200:2500); xlabel('Wavelength (nm)'), ylabel('Reflectance');

reflectances_g16 = gaussianSmoothing(reflectances, 16);
figure, plot(reflectances_g16'); title('Field Data - Gaussian Smoothing 16');
set(gca,'XTick', 400:200:2500);
xlabel('Wavelength (nm)'), ylabel('Reflectance');

%%
[svm_gaussian_atcor, svm_poly_atcor, svm_rbf_atcor] = get_svm_statistics_canopy_based(species, reflectances, rois);

figure;
plot(smoothing_windows, svm_gaussian_atcor);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');
title(sprintf('Effects of Gaussian Window Size on Classification Accuracy \n (canopy-based) - Polynimial Kernel Order 3'));

figure;
%semilogx(polynomial_orders(1:numel(polynomial_orders)), svm_results_poly(1:numel(polynomial_orders)),'marker', 's');
plot(polynomial_orders, svm_poly_atcor);
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
