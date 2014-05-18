%% setting envi for various calculations
envi_atcor = envi;
envi_flaash = envi;

svm_results_rbf_atcor = svm_results_rbf;
svm_results_poly_atcor = svm_results_poly;
svm_results_gaussian_atcor = svm_results_gaussian;


svm_results_rbf_flaash = svm_results_rbf;
svm_results_poly_flaash = svm_results_poly;
svm_results_gaussian_flaash = svm_results_gaussian;

envi = envi_flaash;
envi = envi_atcor;

%% Figure generations
% fig rbf_atcor_flaash
figure_svm_results_rbf = figure
figure( figure_svm_results_rbf);
semilogx(rbf_sigma_values, svm_results_rbf_atcor, 'kx-',  'MarkerSize', 10, 'LineWidth', 2);
hold on 
semilogx(rbf_sigma_values, svm_results_rbf_flaash, 'ro-', 'LineWidth', 2);
grid on
xlabel('SVM Kernel - RBF (\sigma)'); ylabel('Accuracy (%)');
hleg1 = legend('ATCOR','FLAASH');
 set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
hold off

% fig poly_atcor_flaash
figure_svm_results_poly = figure
figure( figure_svm_results_poly);
semilogx(rbf_sigma_values, svm_results_poly_atcor, 'kx-', 'MarkerSize', 10, 'LineWidth', 2);
hold on 
semilogx(rbf_sigma_values, svm_results_poly_flaash, 'ro-', 'LineWidth', 2);
grid on
xlabel('SVM Kernel - polynomial degree'); ylabel('Accuracy (%)');
hleg1 = legend('ATCOR','FLAASH');
 set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
hold off

% figure gaussian
figure;
boxplot(svm_results_gaussian_atcor, smoothing_windows);
xlabel('Gaussian window size'); ylabel('ATCOR - Accuracy (%)');

figure;
boxplot(svm_results_gaussian_flaash, smoothing_windows);
xlabel('Gaussian window size'); ylabel('FLAASH - Accuracy (%)');