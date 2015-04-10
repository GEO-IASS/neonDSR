
envi03 = enviread('/opt/zshare/zproject/data/neon/morning/f100904t01p00r03rdn_b_sc01_ort_flaashreflectance_img');
envi04 = enviread('/opt/zshare/zproject/data/neon/morning/f100904t01p00r04rdn_b_sc01_ort_flaashreflectance_img');
envi05 = enviread('/opt/zshare/zproject/data/neon/morning/f100904t01p00r05rdn_b_sc01_ort_flaashreflectance_img');

%[~, envi05_figure, envi05_h] = toRGB(envi02.z, 'Flight 05'); 

% TODO : mark field samples on hyperspectral and lidar F_flights.
% TODO : BBL is the good/bad bands


%%




[ F_species, F_reflectances, F_rois, F_northings, F_eastings, F_flights ] = get_field_FLAASH_pixels(envi03, envi04, envi05);

% scale reflectance intensity values to [0,1]
for i=1: size(F_reflectances, 1)
    F_reflectances(i,:) = scalePixel(F_reflectances(i,:));
end

figure, plot(setting.wavelength, F_reflectances'); title('FLAASH: Field Data - Original Form');
set(gca,'XTick', 400:200:2500);
xlabel('Wavelength (nm)'), ylabel('Reflectance');

F_reflectances_rwab1 = removeWaterAbsorbtionBands(F_reflectances,1);
figure, plot(setting.wavelength, F_reflectances_rwab1'); title('Field Data - Removed Water Absorption Bands');
set(gca,'XTick', 400:200:2500);
xlabel('Wavelength (nm)'), ylabel('Reflectance');


F_reflectances_rwab0 = removeWaterAbsorbtionBands(F_reflectances,0);
F_chopped_wavelength =  removeWaterAbsorbtionBands(setting.wavelength,0);
figure, plot(F_chopped_wavelength, F_reflectances_rwab0'); title('Field Data - Truncated Water Absorption Bands');
set(gca,'XTick', 400:200:2500);
xlabel('Wavelength (nm)'), ylabel('Reflectance');

F_reflectances_g16 = gaussianSmoothing(F_reflectances, 16);
figure, plot(F_reflectances_g16'); title('Field Data - Gaussian Smoothing 16');
set(gca,'XTick', 400:200:2500);
xlabel('Wavelength (nm)'), ylabel('Reflectance');

F_DEBUG = 1;
F_POLYNOMIAL_DEGREE = 3;
RBF_SIGMA = 10000;


%%
F_reflectances_g4 = gaussianSmoothing(F_reflectances, 4);

temp = svmMultiClassKFold_canopy_based(F_species, F_rois, F_reflectances_g4, F_DEBUG, 'rbf', RBF_SIGMA);
disp(temp);

%%
% Evaluate Gaussian filter size on accuracy
rng(982451653); % large prime as seed for random generation

%matlabpool(8)

F_count = 16;
F_svm_results_canopy_gaussian = nan(F_count, 1);
F_smoothing_windows = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];

parfor i=1:numel(F_smoothing_windows)
    try
        i
        F_smoothing_window_size = F_smoothing_windows(i);
        % Extract ground pixels
        % make suresmoothing is applied on extracted data with the same level as desired
        %[specie_titles, F_reflectances] = extractPixels( envi, fieldPath );
        F_reflectances_g = gaussianSmoothing(F_reflectances_rwab0, F_smoothing_window_size);
        F_svm_results_canopy_gaussian(i) = svmMultiClassKFold_canopy_based(F_species, F_rois, F_reflectances_g, F_DEBUG, 'rbf', RBF_SIGMA);
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
%figure;
%boxplot(svm_results_gaussian, smoothing_windows);
%xlabel('Gaussian window size'); ylabel('Accuracy (%)');

figure;
plot(F_smoothing_windows, F_svm_results_canopy_gaussian);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');
title(sprintf('FLAASH: Effects of Gaussian Window Size on Classification Accuracy \n (canopy-based) - rbf 10000'));

% ---------------------------------------------------------------------
% Evaluate polynomial degree of svm kernel for accuracy
rng(982451653); % large prime as seed for random generation

% Extract ground pixels
%[specie_titles, F_reflectances] = extractPixels( envi, 4 ); % Gaussian window of size 4

F_polynomial_orders = [1 2 3 4 5 6 7 8];  % beyon this point it does not converge
F_count = numel(F_polynomial_orders);
F_svm_results_canopy_poly = NaN(F_count, 1);
F_reflectances_g2 = gaussianSmoothing(F_reflectances_rwab0, 2);

F_reflectances_g4 = gaussianSmoothing(F_reflectances_rwab0, 4);


%matlabpool(8)

parfor i=1:F_count
    try
        i        
        F_svm_results_canopy_poly(i) = svmMultiClassKFold_canopy_based(F_species, F_rois, F_reflectances_g4, F_DEBUG, 'polynomial', F_polynomial_orders(i));
        
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
figure;
%semilogx(polynomial_orders(1:numel(polynomial_orders)), svm_results_poly(1:numel(polynomial_orders)),'marker', 's');
plot(F_polynomial_orders(1:8), F_svm_results_canopy_poly(1:8));
xlabel('SVM Kernel - polynomial degree'); ylabel('Accuracy (%)');
title(sprintf('FLAASH: Effects of Polynomial Order on Classification Accuracy (canopy-based)'));

% ---------------------------------------------------------------------
% Evaluate RBF sigma of svm kernel for accuracy
rng(982451653); % large prime as seed for random generation

% Extract ground pixels
%[specie_titles, F_reflectances] = extractPixels( envi, 4 ); % Gaussian window of size 4

F_rbf_sigma_values = [ 0.001 0.01 0.1 1 2 3 4 5 6 7 8 9 10 100 1000 10000, ...
    20000 40000 60000 80000 100000 1000000 10000000 100000000];

%matlabpool(8)

F_count = numel(F_rbf_sigma_values);
F_svm_results_canopy_rbf = zeros(F_count, 1);

parfor i=1:F_count
    try
        i
        %svm_results_rbf(i) = svmMultiClassKFold(specie_titles, F_reflectances, 1, 'rbf', rbf_sigma_values(i));
        F_svm_results_canopy_rbf(i) = svmMultiClassKFold_canopy_based(F_species, F_rois, F_reflectances_g4, F_DEBUG, 'rbf', F_rbf_sigma_values(i));
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
figure;
semilogx(F_rbf_sigma_values, F_svm_results_canopy_rbf);
grid on
xlabel('SVM Kernel - RBF (\sigma)'); ylabel('Accuracy (%)');
title('FLAASH: Effects of RBF Kernel \sigma on SVM Classification Accuracy (canopy-based)');



%% verify robustness: We achieve the same performance even in absense of cross-validation
% and this demonstrates  the robustness of our classifier implementation
% and data model.

% Evaluate Gaussian filter size on accuracy
rng(982451653); % large prime as seed for random generation

count = 80;
F_svm_results_canopy_gaussian13_23 = nan(count, 1);
smoothing_windows_13_23 = zeros(count, 1);

for i=1:count
    try
        i
        smoothing_window_size =  rem(i,16);  % 5 runs per gaussian window
        smoothing_windows_13_23(i) = smoothing_window_size;
        
        reflectances_g = gaussianSmoothing(reflectances_rwab0, smoothing_window_size);
        F_svm_results_canopy_gaussian13_23(i) = svmMultiClass_canopy_based(species, rois, reflectances_g, DEBUG, 'rbf', RBF_SIGMA)
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
figure;
boxplot(F_svm_results_canopy_gaussian13_23, smoothing_windows_13_23);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');







%%


%%

%%

%%



% Evaluate Gaussian filter size on accuracy after removing low NDVI NIR

F_ndvi = toNDVI(F_reflectances);
F_green_ndvi_reflectances = F_reflectances;
for i=1:numel(F_ndvi)
        if F_ndvi(i) < setting.NDVI_THRESHOLD
            F_green_ndvi_reflectances(i, :)  = nan;
        end
        
        if F_green_ndvi_reflectances(i,setting.NIR_INDEX) < setting.NIR_THRESHOLD
            F_green_ndvi_reflectances(i, :)  = nan;
        end
    
end         
F_low_ndvi_indexes = ~any(~isnan(F_green_ndvi_reflectances), 2);

F_green_ndvi_species = species;
F_green_ndvi_rois = rois;
F_green_ndvi_reflectances(F_low_ndvi_indexes,:)=[]; % from 1269 to 712
F_green_ndvi_species(F_low_ndvi_indexes) = [];    %TODO grid search for parameters 
F_green_ndvi_rois(F_low_ndvi_indexes) = [];



F_nongreen_ndvi_reflectances = reflectances;
F_nongreen_ndvi_reflectances(~F_low_ndvi_indexes,:)=[];











% Evaluate Gaussian filter size on accuracy without removing water absorption bands

rng(982451653); % large prime as seed for random generation

%matlabpool(8)

count = 16;
F_svm_results_canopy_gaussian_before_removing_wab = nan(count, 1);
smoothing_windows = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];

parfor i=1:numel(smoothing_windows)
    try
        i
        smoothing_window_size = smoothing_windows(i);
        % Extract ground pixels
        % make suresmoothing is applied on extracted data with the same level as desired
        %[specie_titles, reflectances] = extractPixels( envi, fieldPath );
        reflectances_g = gaussianSmoothing(reflectances, smoothing_window_size);
        F_svm_results_canopy_gaussian_after_removing_ndvi(i) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g, DEBUG, 'rbf', RBF_SIGMA);
    catch me
        fprintf('image #%i failed training: %s\n',i,me.message)
    end
end
%figure;
%boxplot(svm_results_gaussian, smoothing_windows);
%xlabel('Gaussian window size'); ylabel('Accuracy (%)');

figure;
plot(smoothing_windows, F_svm_results_canopy_gaussian_after_removing_ndvi);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');
title(sprintf('FLAASH: Effects of Gaussian Window Size on Classification Accuracy \n (canopy-based) - rbf 10000 - before removing water abrosption bands'));


