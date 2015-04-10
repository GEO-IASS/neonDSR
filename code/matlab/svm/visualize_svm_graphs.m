


max(F_svm_results_canopy_rbf(:))
max(svm_results_canopy_rbf(:))
max(svm_results_canopy_poly(:))
max(F_svm_results_canopy_poly(:))

[v,ind]=max(F_svm_results_canopy_rbf);
[v1,ind1]=max(max(F_svm_results_canopy_rbf));
disp(['The largest element in X is' num2str(v1) ' at (' num2str(ind(ind1)) ',' num2str(ind1) ') valued at: ' num2str(F_svm_results_canopy_rbf(ind(ind1),ind1)) ' sigma: ' num2str(rbf_sigma_values(ind(ind1)))]);



%% Figure generations
% fig rbf_atcor_flaash
figure_svm_results_rbf = figure
figure( figure_svm_results_rbf);
semilogx(rbf_sigma_values, svm_results_canopy_rbf, 'kx-',  'MarkerSize', 10, 'LineWidth', 2);
hold on 
semilogx(rbf_sigma_values, F_svm_results_canopy_rbf, 'ro-', 'LineWidth', 2);
grid on
xlabel('SVM Kernel - RBF (\sigma)'); ylabel('Accuracy (%)');
hleg1 = legend('ATCOR','FLAASH');
 set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
hold off

% fig poly_atcor_flaash
figure_svm_results_poly = figure
figure( figure_svm_results_poly);
plot(polynomial_orders, svm_results_canopy_poly, 'kx-', 'MarkerSize', 10, 'LineWidth', 2);
hold on 
plot(polynomial_orders, F_svm_results_canopy_poly, 'ro-', 'LineWidth', 2);
grid on
xlabel('SVM Kernel - polynomial degree'); ylabel('Accuracy (%)');
hleg1 = legend('ATCOR','FLAASH');
 set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
hold off

% figure gaussian
figure('name','after removing WABs');
plot(smoothing_windows, svm_results_canopy_gaussian, 'kx-', 'MarkerSize', 10, 'LineWidth', 2);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');
hold on
plot(smoothing_windows, F_svm_results_canopy_gaussian, 'ro-', 'LineWidth', 2);
hleg1 = legend('ATCOR','FLAASH');
 set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
hold off

% figure before removing water absorption bands
figure('name','Before removing WABs');
plot(smoothing_windows, svm_results_canopy_gaussian_before_removing_wab, 'kx-', 'MarkerSize', 10, 'LineWidth', 2);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');
hold on
plot(smoothing_windows, F_svm_results_canopy_gaussian_before_removing_wab, 'ro-', 'LineWidth', 2);
hleg1 = legend('ATCOR','FLAASH');
 set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
hold off


% figure before removing water absorption bands
figure('name','after removing NDVI NIR');
plot(smoothing_windows, svm_results_canopy_gaussian_after_removing_ndvi, 'kx-', 'MarkerSize', 10, 'LineWidth', 2);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');
hold on
plot(smoothing_windows, F_svm_results_canopy_gaussian_after_removing_ndvi, 'ro-', 'LineWidth', 2);
hleg1 = legend('ATCOR','FLAASH');
 set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
hold off



