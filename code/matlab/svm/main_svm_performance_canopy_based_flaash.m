%% ATCOR-based: SVM performance takes on traon/test sets from mutually exlusive canopy sets (ROI).
% in all below F represents it is for flaash data, to avoid mistaking them
% with atcor data
init();
global setting;
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/io'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/io/csvIO'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/svm'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/hyperspectral'));


% scale reflectance intensity values to [0,1]
for i=1: size(reflectancesF, 1)
    reflectancesF(i,:) = scalePixel(reflectancesF(i,:));
end

figure, plot(setting.wavelength, reflectancesF'); title('Field Data - Original Form');
set(gca,'XTick', 400:200:2500);
xlabel('Wavelength (nm)'), ylabel('Reflectance');

reflectances_rwab1F = removeWaterAbsorbtionBands(reflectancesF,1);
figure, plot(setting.wavelength, reflectances_rwab1F'); title('Field Data - Removed Water Absorption Bands');
set(gca,'XTick', 400:200:2500);
xlabel('Wavelength (nm)'), ylabel('Reflectance');


reflectances_rwab0F = removeWaterAbsorbtionBands(reflectancesF,0);
chopped_wavelength =  removeWaterAbsorbtionBands(setting.wavelength,0);
figure, plot(chopped_wavelength, reflectances_rwab0F'); title('Field Data - Truncated Water Absorption Bands');
set(gca,'XTick', 400:200:2500);
xlabel('Wavelength (nm)'), ylabel('Reflectance');

reflectances_g16F = gaussianSmoothing(reflectancesF, 16);
figure, plot(reflectances_g16F'); title('Field Data - Gaussian Smoothing 16');
set(gca,'XTick', 400:200:2500);
xlabel('Wavelength (nm)'), ylabel('Reflectance');

DEBUG = 1;
POLYNOMIAL_DEGREE = 3;

%%

svm_results_gaussianF = svmMultiClassKFold_canopy_based(species, rois, reflectances_rwab0F, DEBUG, 'polynomial', POLYNOMIAL_DEGREE);
disp(svm_results_gaussianF);

%%

matlabpool(8)


%%
% Evaluate Gaussian filter size on accuracy
rng(982451653); % large prime as seed for random generation


count = 16;
svm_results_gaussianF = nan(count, 1);
smoothing_windows = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];

parfor i=1:numel(smoothing_windows)
    try
        i
        smoothing_window_size = smoothing_windows(i);
        % Extract ground pixels
        % make suresmoothing is applied on extracted data with the same level as desired
        %[specie_titles, reflectances] = extractPixels( envi, fieldPath );
        reflectances_gF = gaussianSmoothing(reflectances_rwab0, smoothing_window_size);
        svm_results_gaussianF(i) = svmMultiClassKFold_canopy_based(species, rois, reflectances_gF, DEBUG, 'polynomial', POLYNOMIAL_DEGREE);
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
%figure;
%boxplot(svm_results_gaussian, smoothing_windows);
%xlabel('Gaussian window size'); ylabel('Accuracy (%)');

figure;
plot(smoothing_windows, svm_results_gaussianF);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');
title(sprintf('Effects of Gaussian Window Size on Classification Accuracy \n (canopy-based) - Polynimial Kernel Order 3'));

% ---------------------------------------------------------------------
% Evaluate polynomial degree of svm kernel for accuracy
rng(982451653); % large prime as seed for random generation

% Extract ground pixels
%[specie_titles, reflectances] = extractPixels( envi, 4 ); % Gaussian window of size 4

polynomial_orders = [1 2 3 4 5 6 6 7 8];  % beyon this point it does not converge
count = numel(polynomial_orders);
svm_results_polyF = NaN(count, 1);
reflectances_g2F = gaussianSmoothing(reflectances_rwab0F, 2);

%matlabpool(8)

parfor i=1:count
    try
        i
        svm_results_polyF(i) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g2F, DEBUG, 'polynomial', polynomial_orders(i));
        
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
figure;
%semilogx(polynomial_orders(1:numel(polynomial_orders)), svm_results_poly(1:numel(polynomial_orders)),'marker', 's');
plot(polynomial_orders(1:8), svm_results_polyF(1:8));
xlabel('SVM Kernel - polynomial degree'); ylabel('Accuracy (%)');
title(sprintf('Effects of Polynomial Order on Classification Accuracy (canopy-based)'));

% -------------------------------------------------------------------------
% Evaluate RBF sigma of svm kernel for accuracy
rng(982451653); % large prime as seed for random generation

% Extract ground pixels
%[specie_titles, reflectances] = extractPixels( envi, 4 ); % Gaussian window of size 4

rbf_sigma_values = [ 0.001 0.01 0.1 1 2 3 4 5 6 7 8 9 10 100 1000 10000, ...
    20000 40000 60000 80000 100000 1000000 10000000 100000000];

%matlabpool(8)

count = numel(rbf_sigma_values);
svm_results_rbfF = zeros(count, 1);

parfor i=1:count
    try
        i
        %svm_results_rbf(i) = svmMultiClassKFold(specie_titles, reflectances, 1, 'rbf', rbf_sigma_values(i));
        svm_results_rbfF(i) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g2, DEBUG, 'rbf', rbf_sigma_values(i));
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
figure;
semilogx(rbf_sigma_values, svm_results_rbfF);
grid on
xlabel('SVM Kernel - RBF (\sigma)'); ylabel('Accuracy (%)');
title('Effects of RBF Kernel \sigma on SVM Classification Accuracy (canopy-based)');

%%

% best performance confusion matrix

rng(982451653); % large prime as seed for random generation
rbf_sigma_bestF = 10000;
svm_result_bestF = svmMultiClassKFold_canopy_based(species, rois, reflectances_g2F, DEBUG, 'rbf', rbf_sigma_best);
