%% SVM performance takes on traon/test sets from mutually exlusive canopy sets (ROI).
init();
global setting;
fieldPath = setting.FIELD_PATH;
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/io'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/io/csvIO'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/svm'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/hyperspectral'));


[ species, reflectances, rois, northings, eastings, flights ] = get_field_pixels();

% scale reflectance intensity values to [0,1]
for i=1: size(reflectances, 1)
    reflectances(i,:) = scalePixel(reflectances(i,:));
end

figure, plot(setting.wavelength, reflectances'); title('Field Data - Original Form');
set(gca,'XTick', 400:200:2500);
xlabel('Wavelength (nm)'), ylabel('Reflectance');

reflectances_rwab1 = removeWaterAbsorbtionBands(reflectances,1);
figure, plot(setting.wavelength, reflectances_rwab1'); title('Field Data - Removed Water Absorption Bands');
set(gca,'XTick', 400:200:2500);
xlabel('Wavelength (nm)'), ylabel('Reflectance');


reflectances_rwab0 = removeWaterAbsorbtionBands(reflectances,0);
chopped_wavelength =  removeWaterAbsorbtionBands(setting.wavelength,0);
figure, plot(chopped_wavelength, reflectances_rwab0'); title('Field Data - Truncated Water Absorption Bands');
set(gca,'XTick', 400:200:2500);
xlabel('Wavelength (nm)'), ylabel('Reflectance');

reflectances_g16 = gaussianSmoothing(reflectances, 16);
figure, plot(reflectances_g16'); title('Field Data - Gaussian Smoothing 16');
set(gca,'XTick', 400:200:2500);
xlabel('Wavelength (nm)'), ylabel('Reflectance');

DEBUG = 1;
POLYNOMIAL_DEGREE = 3;

%%

svm_results_canopy_gaussian = svmMultiClassKFold_canopy_based(species, rois, reflectances_rwab0, DEBUG, 'polynomial', POLYNOMIAL_DEGREE);
disp(svm_results_canopy_gaussian);

%%
% Evaluate Gaussian filter size on accuracy
rng(982451653); % large prime as seed for random generation

%matlabpool(8)

count = 16;
svm_results_canopy_gaussian = nan(count, 1);
smoothing_windows = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];

parfor i=1:numel(smoothing_windows)
    try
        i
        smoothing_window_size = smoothing_windows(i);
        % Extract ground pixels
        % make suresmoothing is applied on extracted data with the same level as desired
        %[specie_titles, reflectances] = extractPixels( envi, fieldPath );
        reflectances_g = gaussianSmoothing(reflectances_rwab0, smoothing_window_size);
        svm_results_canopy_gaussian(i) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g, DEBUG, 'polynomial', POLYNOMIAL_DEGREE);
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
%figure;
%boxplot(svm_results_gaussian, smoothing_windows);
%xlabel('Gaussian window size'); ylabel('Accuracy (%)');

figure;
plot(smoothing_windows, svm_results_canopy_gaussian);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');
title(sprintf('Effects of Gaussian Window Size on Classification Accuracy \n (canopy-based) - Polynimial Kernel Order 3'));

% ---------------------------------------------------------------------
% Evaluate polynomial degree of svm kernel for accuracy
rng(982451653); % large prime as seed for random generation

% Extract ground pixels
%[specie_titles, reflectances] = extractPixels( envi, 4 ); % Gaussian window of size 4

polynomial_orders = [1 2 3 4 5 6 6 7 8];  % beyon this point it does not converge
count = numel(polynomial_orders);
svm_results_canopy_poly = NaN(count, 1);
reflectances_g2 = gaussianSmoothing(reflectances_rwab0, 2);

reflectances_g4 = gaussianSmoothing(reflectances_rwab0, 4);


%matlabpool(8)

parfor i=1:count
    try
        i        
        svm_results_canopy_poly(i) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g4, DEBUG, 'polynomial', polynomial_orders(i));
        
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
figure;
%semilogx(polynomial_orders(1:numel(polynomial_orders)), svm_results_poly(1:numel(polynomial_orders)),'marker', 's');
plot(polynomial_orders(1:8), svm_results_canopy_poly(1:8));
xlabel('SVM Kernel - polynomial degree'); ylabel('Accuracy (%)');
title(sprintf('Effects of Polynomial Order on Classification Accuracy (canopy-based)'));

% ---------------------------------------------------------------------
% Evaluate RBF sigma of svm kernel for accuracy
rng(982451653); % large prime as seed for random generation

% Extract ground pixels
%[specie_titles, reflectances] = extractPixels( envi, 4 ); % Gaussian window of size 4

rbf_sigma_values = [ 0.001 0.01 0.1 1 2 3 4 5 6 7 8 9 10 100 1000 10000, ...
    20000 40000 60000 80000 100000 1000000 10000000 100000000];

%matlabpool(8)

count = numel(rbf_sigma_values);
svm_results_canopy_rbf = zeros(count, 1);

parfor i=1:count
    try
        i
        %svm_results_rbf(i) = svmMultiClassKFold(specie_titles, reflectances, 1, 'rbf', rbf_sigma_values(i));
        svm_results_canopy_rbf(i) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g4, DEBUG, 'rbf', rbf_sigma_values(i));
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
figure;
semilogx(rbf_sigma_values, svm_results_canopy_rbf);
grid on
xlabel('SVM Kernel - RBF (\sigma)'); ylabel('Accuracy (%)');
title('Effects of RBF Kernel \sigma on SVM Classification Accuracy (canopy-based)');

%% verify robustness: We achieve the same performance even in absense of cross-validation
% and this demonstrates  the robustness of our classifier implementation
% and data model.




% Evaluate Gaussian filter size on accuracy
rng(982451653); % large prime as seed for random generation



count = 100;
svm_results_canopy_gaussian = NaN(count, 1);
smoothing_windows = zeros(count, 1);

for i=1:count
    try
        i
        smoothing_window_size =  rem(i,10);  % 25 runs per gaussian window
        smoothing_windows(i) = smoothing_window_size;
        % Extract ground pixels
        [specie_titles, reflectances] = extractPixels( envi, smoothing_window_size);
        svm_results_canopy_gaussian(i) = svmMultiClass(specie_titles, reflectances, 0);
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
figure;
boxplot(svm_results_canopy_gaussian, smoothing_windows);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');



















%%


%%


%%

