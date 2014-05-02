% Prepare data
fieldData = '/cise/homes/msnia/zproject/neonDSR/docs/field_trip_28022014/crowns_osbs_atcor_flight4_morning.csv';

fileID = fopen(fieldData);
% file_columns is an array of cells each of which is an array of items
file_columns = textscan(fileID, ['%s %f %f %f %f %f %f %f %f %f' ... % {'Specie','Specie_ID','ROI_ID','ID','X','Y','MapX','MapY','Lat','Lon'}
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %20
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %40
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %60
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %80
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %100
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %120
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %140
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %160
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %180
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %200
    '%f %f %f %f %f %f %f %f %f %f' '%f %f %f %f %f %f %f %f %f %f' ... %220    
    '%f %f %f %f' %224   ---  224 wavelengths
    ], ...    
'delimiter',',','EmptyValue',-Inf, 'headerLines', 1);
fclose(fileID);

specie_titles = file_columns{1,1,:}; % char(file_columns{1,1,:});
a = [file_columns(1, 2:numel(file_columns))]';
numerical_part_of_file=reshape(cell2mat(a), numel(file_columns{1}), numel(file_columns)-1); % one column containing textual info (specie name)

%shuffle
random_permutations = randperm(size(numerical_part_of_file,1));
shuffledArray = numerical_part_of_file(random_permutations,:); % samples_reflectance is ordered by specie, shuffle it
shuffled_species = specie_titles(random_permutations, :);

shuffled_samples_reflectance = shuffledArray(:, 11:numel(file_columns)-1);

%% svm part

meas = shuffled_samples_reflectance;
species = shuffled_species;

%Example multi-class

groups = shuffled_species;
total_samples = shuffled_samples_reflectance;

[g gn] = grp2idx(groups);      %# nominal class to numeric (string classes to numeric)


k=10;

cvFolds = crossvalind('Kfold', groups, k);   %# get indices of 10-fold CV
%cp = classperf(groups);                      %# init performance tracker

sum_accuracy = 0;

for i = 1:k                                  %# for each fold
    testIdx = (cvFolds == i);                %# get indices of test instances
    trainIdx = ~testIdx;                     %# get indices training instances



             
             
             
    pairwise = nchoosek(1:length(gn),2);            %# 1-vs-1 pairwise models [1,2;1,3;2,3]
    svmModel = cell(size(pairwise,1),1);            %# NchooseK binary-classifers: one classifier for each [1,2;1,3;2,3]
    predTest = zeros(sum(testIdx),numel(svmModel)); %# binary predictions - three predictions per test (one for each classfier above)

    %# classify using one-against-one approach, SVM with 3rd degree poly kernel
    for j=1:numel(svmModel)
        %# get only training instances belonging to this pair
        selector = any( bsxfun(@eq, g, pairwise(j,:)) , 2 );
        idx = trainIdx & selector;

        %# train
       svmModel{j} = svmtrain(meas(idx,:), g(idx), ...
            'BoxConstraint',2e-1, 'Kernel_Function','polynomial', 'Polyorder',3);
        
        
      % svmModel{j} = svmtrain(meas(idx,:), g(idx), ...
       %          'Autoscale',true, 'Showplot',false, 'Method','QP', ...
       %          'BoxConstraint',2e-1, 'Kernel_Function','rbf', 'RBF_Sigma',1);

        %# test
        predTest(:,j) = svmclassify(svmModel{j}, meas(testIdx,:));
    end
    pred = mode(predTest,2);   %# voting: clasify as the class receiving most votes
                           % Find the most frequent value of each column.

    %# performance
    [cmat, order] = confusionmat(g(testIdx),pred);
    acc = 100*sum(diag(cmat))./sum(cmat(:));
    fprintf('SVM (1-against-1):\naccuracy = %.2f%%\n', acc);
    fprintf('Confusion Matrix:\n'), disp(cmat)
    order
    gn
    
    
    sum_accuracy = sum_accuracy + acc;


             
             
             
             
             
             
             
             
             
    %# test using test instances
    %pred = svmclassify(svmModel, total_samples(testIdx,:), 'Showplot',false);

    %# evaluate and update performance object
    %cp = classperf(cp, pred, testIdx);
end


avg_accuracy = sum_accuracy / k

%# get accuracy
%disp(['CorrectRate: %' num2str( cp.CorrectRate)]);

%# get confusion matrix
%# columns:actual, rows:predicted, last-row: unclassified instances
%cp.CountingMatrix

%disp(['Time: ' datestr(now, 'HH:MM:SS')])


% confudion matrix
% multiclass clasification: 1vs all 1vs 1/.
