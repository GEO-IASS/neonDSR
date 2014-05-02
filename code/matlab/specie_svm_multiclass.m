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




%%

meas = shuffled_samples_reflectance;
species = shuffled_species;

%Example multi-class
%# load dataset
%load fisheriris
[g gn] = grp2idx(species);      %# nominal class to numeric (string classes to numeric)

%# split training/testing sets
[trainIdx testIdx] = crossvalind('HoldOut', species, 1/3);  % 0/1 specifying train or test

pairwise = nchoosek(1:length(gn),2);            %# 1-vs-1 pairwise models [1,2;1,3;2,3]
svmModel = cell(size(pairwise,1),1);            %# NchooseK binary-classifers: one classifier for each [1,2;1,3;2,3]
predTest = zeros(sum(testIdx),numel(svmModel)); %# binary predictions - three predictions per test (one for each classfier above)

%# classify using one-against-one approach, SVM with 3rd degree poly kernel
for k=1:numel(svmModel)
    %# get only training instances belonging to this pair
    selector = any( bsxfun(@eq, g, pairwise(k,:)) , 2 );
    idx = trainIdx & selector;

    %# train
    svmModel{k} = svmtrain(meas(idx,:), g(idx), ...
        'BoxConstraint',2e-1, 'Kernel_Function','polynomial', 'Polyorder',3);

    %# test
    predTest(:,k) = svmclassify(svmModel{k}, meas(testIdx,:));
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





