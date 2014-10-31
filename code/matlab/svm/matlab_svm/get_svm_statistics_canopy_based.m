function [svm_results_gaussian, svm_results_poly, svm_results_rbf ] = get_svm_statistics_canopy_based(species, reflectances, rois)
%% This function collects all necerrary statistics from differnet classification schemes

%% ATCOR-based: SVM performance takes on traon/test sets from mutually exlusive canopy sets (ROI).
init();
global setting;

%matlabpool(8)
svm_results_gaussian = 0; svm_results_poly = 0; svm_results_rbf = 0;
POLYNOMIAL_DEGREE = 3;

%%
% % Evaluate Gaussian filter size on accuracy
% rng(setting.RANDOM_VALUE_SEED); 
% 
% smoothing_windows = setting.SVM_GAUSSIAN_SMOOTHING_WINDOWS;
% svm_results_gaussian = nan(numel(smoothing_windows), 1);
% 
% parfor i=1:numel(smoothing_windows)
%     try
%         i
%         reflectances_g = gaussianSmoothing(reflectances, smoothing_windows(i));
%         svm_results_gaussian(i) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g, 'polynomial', POLYNOMIAL_DEGREE);
%         disp('done Gaussian')
%     catch me
%         fprintf('Gaussian smoothing #%i failed training: %s\n', smoothing_windows(i), me.message)
%     end
% end

% ---------------------------------------------------------------------
% Evaluate polynomial degree of svm kernel for accuracy
rng(setting.RANDOM_VALUE_SEED);

polynomial_orders = setting.SVM_POLYNOMIAL_ORDERS;  % beyon this point it does not converge
count = numel(polynomial_orders);
svm_results_poly = NaN(count, 1);
reflectances_g2 = gaussianSmoothing(reflectances, 2);

for i=1:count
    try
        i
        svm_results_poly(i) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g2, 'polynomial', polynomial_orders(i));
        disp('done Poly')
    catch me
        fprintf('Polynomial order #%i failed training: %s\n',polynomial_orders(i),me.message)
    end
end

% -------------------------------------------------------------------------
% Evaluate RBF sigma of svm kernel for accuracy
% rng(setting.RANDOM_VALUE_SEED);
% 
% rbf_sigma_values = setting.SVM_RBF_SIGMA_VALUES;
% count = numel(rbf_sigma_values);
% svm_results_rbf = zeros(count, 1);
% 
% for i=1:count
%     try
%         i
%         svm_results_rbf(i) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g2, 'rbf', rbf_sigma_values(i));
%         disp('done rbf')
%     catch me
%         fprintf('RBF sigma #%i failed training: %s\n', rbf_sigma_values(i), me.message)
%     end
% end


end