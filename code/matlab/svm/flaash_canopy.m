
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

figure, plot(setting.wavelength, F_reflectances'); title('Field Data - Original Form');
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

%%

F_svm_results_canopy_gaussian = svmMultiClassKFold_canopy_based(F_species, F_rois, F_reflectances_rwab0, F_DEBUG, 'polynomial', F_POLYNOMIAL_DEGREE);
disp(F_svm_results_canopy_gaussian);

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
        F_svm_results_canopy_gaussian(i) = svmMultiClassKFold_canopy_based(F_species, F_rois, F_reflectances_g, F_DEBUG, 'polynomial', F_POLYNOMIAL_DEGREE);
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
title(sprintf('FLAASH: Effects of Gaussian Window Size on Classification Accuracy \n (canopy-based) - Polynimial Kernel Order 3'));

% ---------------------------------------------------------------------
% Evaluate polynomial degree of svm kernel for accuracy
rng(982451653); % large prime as seed for random generation

% Extract ground pixels
%[specie_titles, F_reflectances] = extractPixels( envi, 4 ); % Gaussian window of size 4

F_polynomial_orders = [1 2 3 4 5 6 6 7 8];  % beyon this point it does not converge
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