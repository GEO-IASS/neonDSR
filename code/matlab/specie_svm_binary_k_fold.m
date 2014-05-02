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
%disp(['Time: ' datestr(now, 'HH:MM:SS')])

% SVM

groups = shuffled_species;
total_samples = shuffled_samples_reflectance;
%groups = ismember(total_classes,3);

k=10;

cvFolds = crossvalind('Kfold', groups, k);   %# get indices of 10-fold CV
%cp = classperf(groups);                      %# init performance tracker

for i = 1:k                                  %# for each fold
    testIdx = (cvFolds == i);                %# get indices of test instances
    trainIdx = ~testIdx;                     %# get indices training instances

    %# train an SVM model over training instances
    svmModel = svmtrain(total_samples(trainIdx,:), groups(trainIdx), ...
                 'Autoscale',true, 'Showplot',false, 'Method','QP', ...
                 'BoxConstraint',2e-1, 'Kernel_Function','rbf', 'RBF_Sigma',1);

    %# test using test instances
    pred = svmclassify(svmModel, total_samples(testIdx,:), 'Showplot',false);

    %# evaluate and update performance object
    %cp = classperf(cp, pred, testIdx);
end

%# get accuracy
%disp(['CorrectRate: %' num2str( cp.CorrectRate)]);

%# get confusion matrix
%# columns:actual, rows:predicted, last-row: unclassified instances
cp.CountingMatrix

%disp(['Time: ' datestr(now, 'HH:MM:SS')])


% confudion matrix
% multiclass clasification: 1vs all 1vs 1/.
