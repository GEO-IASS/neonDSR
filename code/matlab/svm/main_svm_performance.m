%% SVM performance



%%
% Evaluate Gaussian filter size on accuracy
rng(982451653); % large prime as seed for random generation



count = 100;
svm_results_gaussian = zeros(count, 1);
smoothing_windows = zeros(count, 1);

for i=1:count
    i
    smoothing_window_size =  rem(i,10);  % 25 runs per gaussian window
    smoothing_windows(i) = smoothing_window_size;
    % Extract ground pixels  
    % make suresmoothing is applied on extracted data with the same level as desired 
    [specie_titles, reflectances] = extractPixels( envi, smoothing_window_size ); 
    svm_results_gaussian(i) = svmMultiClassKFold(specie_titles, reflectances, 0, 'polynomial', 3);
end
figure;
boxplot(svm_results_gaussian, smoothing_windows);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');

%---------------------------------------------------------------------
% Evaluate polynomial degree of svm kernel for accuracy
rng(982451653); % large prime as seed for random generation

% Extract ground pixels  
[specie_titles, reflectances] = extractPixels( envi, 4 ); % Gaussian window of size 4

% polynomial_orders = [ 0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.007 0.008 0.009 ...
%     0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 ...
%     0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 ...
%     1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 ...
%     2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 ...
%     3 3.1 3.15 3.2 3.25  3.3 3.33 3.35 3.4 3.5 3.6 3.7 3.8 3.9...
%     4 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 ...
%     5 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8 5.9 ...
%     6 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 ...
%     7 8 9 10]; %[ 1 2 3 4 5 6 7 8 9 10];
 polynomial_orders = [ 1];
count = numel(polynomial_orders);
svm_results_poly = zeros(count, 1);

for i=1:count
    i
    svm_results_poly(i) = svmMultiClassKFold(specie_titles, reflectances, 1, 'polynomial', polynomial_orders(i));
end
figure;
semilogx(polynomial_orders(1:numel(polynomial_orders)), svm_results_poly(1:numel(polynomial_orders)),'marker', 's');
xlabel('SVM Kernel - polynomial degree'); ylabel('Accuracy (%)');

%---------------------------------------------------------------------
% Evaluate RBF sigma of svm kernel for accuracy
rng(982451653); % large prime as seed for random generation

% Extract ground pixels  
[specie_titles, reflectances] = extractPixels( envi, 4 ); % Gaussian window of size 4

% rbf_sigma_values = [ 0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.007 0.008 0.009 ...
%     0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 ...
%     0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 ...
%     1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 ...
%     2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 ...
%     3 3.1 3.15 3.2 3.25  3.3 3.33 3.35 3.4 3.5 3.6 3.7 3.8 3.9 ...
%     4 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 ...
%     5 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8 5.9 ...
%     6 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 ...
%     7 8 9 10];
rbf_sigma_values =[4.2];
count = numel(rbf_sigma_values);
svm_results_rbf = zeros(count, 1);

for i=1:count
    i
    svm_results_rbf(i) = svmMultiClassKFold(specie_titles, reflectances, 1, 'rbf', rbf_sigma_values(i));
end
figure;
semilogx(rbf_sigma_values, svm_results_rbf);
grid on
xlabel('SVM Kernel - RBF (\sigma)'); ylabel('Accuracy (%)');


%% verify robustness




% Evaluate Gaussian filter size on accuracy
rng(982451653); % large prime as seed for random generation



count = 100;
svm_results_gaussian = zeros(count, 1);
smoothing_windows = zeros(count, 1);

for i=1:count
    i
    smoothing_window_size =  rem(i,10);  % 25 runs per gaussian window
    smoothing_windows(i) = smoothing_window_size;
    % Extract ground pixels  
    [specie_titles, reflectances] = extractPixels( envi, smoothing_window_size);    
    svm_results_gaussian(i) = svmMultiClass(specie_titles, reflectances, 0);
end
figure;
boxplot(svm_results_gaussian, smoothing_windows);
xlabel('Gaussian window size'); ylabel('Accuracy (%)');