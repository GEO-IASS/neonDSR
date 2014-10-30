function [svm_results_gaussian, svm_results_poly, svm_results_rbf ] = get_libsvm_statistics_canopy_based(species, reflectances, rois)
%% This function collects all necerrary statistics from differnet classification schemes

%% ATCOR-based: SVM performance takes on traon/test sets from mutually exlusive canopy sets (ROI).
init();
global setting;

%matlabpool(8)

POLYNOMIAL_DEGREE = 3;

%%
% ---------------------------------------------------------------------
% Evaluate polynomial degree of svm kernel for accuracy
rng(setting.RANDOM_VALUE_SEED);

svm_results_poly = NaN(numel(setting.LIBSVM_COST_VALUES), numel(setting.SVM_POLYNOMIAL_ORDERS));
reflectances_g2 = gaussianSmoothing(reflectances, 2);

%grid search
for c=1:numel(setting.LIBSVM_COST_VALUES)
    for p=1:numel(setting.SVM_POLYNOMIAL_ORDERS)
        try
            svm_results_poly(c, p) = libsvmMultiClassKFold_canopy_based(species, rois, reflectances_g2, 'polynomial', polynomial_orders(p));
            disp(['done Poly ' p])
        catch me
            fprintf('Polynomial order #%i failed training: %s\n',setting.SVM_POLYNOMIAL_ORDERS(p),me.message)
        end
    end
end

% -------------------------------------------------------------------------
% % Evaluate RBF sigma of svm kernel for accuracy
% rng(setting.RANDOM_VALUE_SEED);
% 
% rbf_sigma_values = setting.SVM_RBF_SIGMA_VALUES;
% count = numel(rbf_sigma_values);
% svm_results_rbf = zeros(count, 1);
% 
% for r=1:count
%     try
%         svm_results_rbf(r) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g2, 'rbf', setting.SVM_RBF_SIGMA_VALUES(r));
%         disp(['done rbf ' r])
%     catch me
%         fprintf('RBF sigma #%i failed training: %s\n', rbf_sigma_values(r), me.message)
%     end
% end
% 
% 
% % Evaluate Gaussian filter size on accuracy on best parameters of
% % polynomial
% rng(setting.RANDOM_VALUE_SEED);
% 
% smoothing_windows = setting.SVM_GAUSSIAN_SMOOTHING_WINDOWS;
% svm_results_gaussian = nan(numel(smoothing_windows), 1);
% 
% for i=1:numel(smoothing_windows)
%     try
%         i
%         reflectances_g = gaussianSmoothing(reflectances, smoothing_windows(i));
%         svm_results_gaussian(i) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g, 'polynomial', POLYNOMIAL_DEGREE);
%         disp('done Gaussian')
%     catch me
%         fprintf('Gaussian smoothing #%i failed training: %s\n', smoothing_windows(i), me.message)
%     end
% end

end