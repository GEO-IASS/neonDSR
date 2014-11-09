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
RBF_SIGMA = 10000;

%%

reflectances_g3 = gaussianSmoothing(reflectances, 3);
temp = svmMultiClassKFold_canopy_based(species, rois, reflectances_rwab0, DEBUG, 'rbf', 10000);
disp(temp);

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
        svm_results_canopy_gaussian(i) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g, DEBUG, 'rbf', RBF_SIGMA);
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
title(sprintf('Effects of Gaussian Window Size on Classification Accuracy \n (canopy-based) - rbf 10000'));

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

%% verify robustness: We achieve the same performance even in absense of cross-validation - DATA HAS HIGH VARIANCE PROBABLY MEANING OUR PARAMETERS ARE OVER FITTING, AND AVERAGE IS LOW GETS TO 65 AT MULTIPLE SPOTS. SO WE DON'T INCLUDE THE ROBUSTNESS FIGURE AND TALK ABOUT IT.
% and this demonstrates  the robustness of our classifier implementation
% and data model.
% Evaluate Gaussian filter size on accuracy
rng(982451653); % large prime as seed for random generation

count = 80;
svm_results_canopy_gaussian13_23 = nan(count, 1);
smoothing_windows_13_23 = zeros(count, 1);

for i=1:count
    try
        i
        smoothing_window_size =  rem(i,16);  % 5 runs per gaussian window
        smoothing_windows_13_23(i) = smoothing_window_size;
        
        reflectances_g = gaussianSmoothing(F_reflectances_rwab0, smoothing_window_size);
        svm_results_canopy_gaussian13_23(i) = svmMultiClass_canopy_based(species, rois, reflectances_g, DEBUG, 'rbf', RBF_SIGMA)
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
figure;
boxplot(svm_results_canopy_gaussian13_23, smoothing_windows_13_23);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');







%%


%%


%%

% Evaluate Gaussian filter size on accuracy without removing water absorption bands

rng(982451653); % large prime as seed for random generation

%matlabpool(8)

count = 16;
svm_results_canopy_gaussian_before_removing_wab = nan(count, 1);
smoothing_windows = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];

parfor i=1:numel(smoothing_windows)
    try
        i
        smoothing_window_size = smoothing_windows(i);
        % Extract ground pixels
        % make suresmoothing is applied on extracted data with the same level as desired
        %[specie_titles, reflectances] = extractPixels( envi, fieldPath );
        reflectances_g = gaussianSmoothing(reflectances, smoothing_window_size);
        svm_results_canopy_gaussian_before_removing_wab(i) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g, DEBUG, 'rbf', RBF_SIGMA);
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
%figure;
%boxplot(svm_results_gaussian, smoothing_windows);
%xlabel('Gaussian window size'); ylabel('Accuracy (%)');

figure;
plot(smoothing_windows, svm_results_canopy_gaussian_before_removing_wab);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');
title(sprintf('Effects of Gaussian Window Size on Classification Accuracy \n (canopy-based) - rbf 10000 - before removing water abrosption bands'));



%%


%%


%%


%%


%%


%%

% Evaluate Gaussian filter size on accuracy after removing low NDVI NIR

ndvi = toNDVI(reflectances);
green_ndvi_reflectances = reflectances;
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



nongreen_ndvi_reflectances = reflectances;
nongreen_ndvi_reflectances(~low_ndvi_indexes,:)=[];


%%

% Evaluate Gaussian filter size on accuracy after removing ndvi nir

rng(982451653); % large prime as seed for random generation

%matlabpool(8)

count = 16;
svm_results_canopy_gaussian_before_removing_wab = nan(count, 1);
smoothing_windows = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];

parfor i=1:numel(smoothing_windows)
    try
        i
        disp('hio')
        smoothing_window_size = smoothing_windows(i);
        % Extract ground pixels
        % make suresmoothing is applied on extracted data with the same level as desired
        %[specie_titles, reflectances] = extractPixels( envi, fieldPath );
        reflectances_g = gaussianSmoothing(green_ndvi_reflectances, smoothing_window_size);
        svm_results_canopy_gaussian_after_removing_ndvi(i) = svmMultiClassKFold_canopy_based(green_ndvi_species, green_ndvi_rois, reflectances_g, DEBUG, 'rbf', RBF_SIGMA);
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
%figure;
%boxplot(svm_results_gaussian, smoothing_windows);
%xlabel('Gaussian window size'); ylabel('Accuracy (%)');

figure;
plot(smoothing_windows, svm_results_canopy_gaussian_after_removing_ndvi);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');
title(sprintf('Effects of Gaussian Window Size on Classification Accuracy \n (canopy-based) - rbf 10000 - before removing water abrosption bands'));

