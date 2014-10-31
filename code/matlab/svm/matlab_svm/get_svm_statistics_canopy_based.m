function [svm_results_gaussian, svm_results_poly, svm_results_rbf ] = get_svm_statistics_canopy_based(species, reflectances, rois, matlabSVM_OR_libSVM)
%% This function collects all necerrary statistics from differnet classification schemes

%% ATCOR-based: SVM performance takes on traon/test sets from mutually exlusive canopy sets (ROI).
init();
global setting;

svm_results_gaussian = 0; svm_results_poly = 0; svm_results_rbf = 0;
POLYNOMIAL_DEGREE = 3;

%%
% Evaluate Gaussian filter size on accuracy
rng(setting.RANDOM_VALUE_SEED);

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

sr = setting.SVM_POLYNOMIAL_ORDERS;
sc = setting.LIBSVM_COST_VALUES;

svm_results_poly = NaN(numel(sr), numel(sc));
reflectances_g2 = gaussianSmoothing(reflectances, 2);


parfor p=1:numel(sr)
    temp = nan(1, numel(sc));
    for c=1:numel(sc)
        try
            %svm_results_poly(p, c) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g2, 'polynomial', sp(p), sc(c) , matlabSVM_OR_libSVM);
            temp(c) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g2, 'polynomial', sr(p), sc(c) , matlabSVM_OR_libSVM);
           % disp('done Poly')
            fprintf('Done poly %i cost %d\n',sr(p), sc(c));
            
        catch me
            fprintf('poly %i cost %d failed training: %s\n',sr(p), sc(c),me.message)
            rethrow(me);
        end
        svm_results_poly(p, :) = temp;
    end
end



% -------------------------------------------------------------------------
% Evaluate RBF sigma of svm kernel for accuracy
rng(setting.RANDOM_VALUE_SEED);

sr = setting.SVM_RBF_SIGMA_VALUES;
sc = setting.LIBSVM_COST_VALUES;

svm_results_rbf = NaN(numel(sr), numel(sc));

parfor r=1:numel(sr)
    temp = nan(1, numel(sc));
    for c=1:numel(sc)
        try
            %svm_results_poly(p, c) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g2, 'polynomial', sp(p), sc(c) , matlabSVM_OR_libSVM);
            temp(c) = svmMultiClassKFold_canopy_based(species, rois, reflectances_g2, 'rbf', sr(r), sc(c) , matlabSVM_OR_libSVM);
           % disp('done Poly')
            fprintf('Done rbf %i cost %d\n',sr(r), sc(c));
            
        catch me
            fprintf('rbf %i cost %d failed training: %s\n',sr(r), sc(c),me.message)
            rethrow(me);
        end
        svm_results_rbf(r, :) = temp;
    end
end


end