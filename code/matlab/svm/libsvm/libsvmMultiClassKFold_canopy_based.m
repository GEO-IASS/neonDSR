function avg_accuracy = libsvmMultiClassKFold_canopy_based(species, rois, features, kernel, c, param) 
%% This is a k-fold classification all-vs-all (as compared to one-vs-all) based on
%using separate canopies for training and test sets. to make sure I do not
% use pixels of a tree both for train and test.
%c is the cost function, param is either gamma or polynomial degre

addpath('/opt/zshare/zproject/apps/libsvm-3.19/matlab');

global setting;
debug = setting.DEBUG;
rng(setting.RANDOM_VALUE_SEED); 

[g gn] = grp2idx(species);      %# nominal class to numeric (string specie to numeric)

%k=10; % one for test 9 for trainning
k = 5; % at most 5 crowns for some species.

%%
% Do SVM on ROIs. (specify which ROIs to be used for train/test - determine
% the train/test ROI index using crossvalind function)

unique_rois = unique(rois);
unique_rois_species =  cell(numel(unique_rois),1);
for i = 1:numel(unique_rois)
    roiIdx = rois == unique_rois(i);
    rois_specie = species(roiIdx);
    unique_rois_species(i) = rois_specie(1);
end

% shuffle unique ROIs species as they are sorted
permutation_idx = randperm(numel(unique_rois_species));
permuted_unique_rois_species = unique_rois_species(permutation_idx);
unique_rois_species = permuted_unique_rois_species;



sum_accuracy = 0;
cvFolds = crossvalind('Kfold', unique_rois_species, k);   %# get indices of 10-fold CV


for i = 1:k                          % Run SVM classificatoin k times (k being the # of folds)
    testIdx = (cvFolds == i);        % get test set indices
    trainIdx = ~testIdx;             % get training indices
    
    % print how many canopies of each specie is selected for test
    if debug
        disp('# Total Crowns, # Test Crowns, Specie');
        for j = 1:numel(gn)
            flagged_for_test_species = unique_rois_species(testIdx);
            flagged_for_test_species_idx = strcmp(flagged_for_test_species, gn(j));
            total_species_idx = strcmp(unique_rois_species, gn(j));
            
            specie = gn(j);
            disp(sprintf('%d, %d, %s', sum(total_species_idx), sum(flagged_for_test_species_idx), specie{1}));
        end
        clear flagged_for_test_species flagged_for_test_species_idx total_species_idx specie
    end
    
    
    pairwise = nchoosek(1:length(gn),2);            %# all-vs-all pairwise models [1,2;1,3;2,3]
    svmModel = cell(size(pairwise,1),1);            %# NchooseK binary-classifers: one classifier for each [1,2;1,3;2,3]
    
    
    
    
    % So I create a matrix where the # of columns is the # of separate classifiers
    % and # of rows is total # of pixels of the canopies that are specified
    % as test set. Later on this will be used to determine where that test
    % pixel belongs to.
    % --
    % # of pixels in the test set is:
    no_of_pixels_in_test_set = 0;
    test_rois = unique_rois(testIdx);
    for j = 1:numel(test_rois)
        no_of_pixels_in_test_set = no_of_pixels_in_test_set + numel(rois(rois == test_rois(j)));
    end
    
    
    %prediction of test set for all classifiers
    predTest = zeros(no_of_pixels_in_test_set,numel(svmModel)); % binary predictions - three predictions per test (one for each classfier above)
    clear no_of_pixels_in_test_set
    
    
    % convert train index of canopies to train index for pixels list
    pixels_trainIdx = zeros(numel(species),1);
    for j = 1:numel(unique_rois_species)
        if trainIdx(j) == 1
            specie = unique_rois_species(j);
            roi = unique_rois(j);
            or1 = pixels_trainIdx;
            or2 = rois == roi;
            pixels_trainIdx =  or1 | or2;
        end
    end
    clear or1 or2 roi specie;
    pixels_testIdx = ~pixels_trainIdx;
    
    
    %# classify using one-against-one approach
    for j=1:numel(svmModel)
        %# get only training instances belonging to this pair
        selector = any( bsxfun(@eq, g, pairwise(j,:)) , 2 );
        
        
        idx = pixels_trainIdx & selector; % training set items that either belong to claas 1 or 2 that comprise of this binary classifier.
        tic
        % train - test
        %  try
        if strcmp(kernel, 'polynomial')
            OPTIONS = optimset('MaxIter', 10000);
            OPTIONS = optimset(OPTIONS, 'UseParallel', 'always');

            svmModel{j} = svmtrain(features(idx,:), g(idx), ...
                'Method','QP',...
                'options', OPTIONS,...
                'BoxConstraint',Inf,...
                'Kernel_Function', kernel,...
                'Polyorder',kernel_param);
        elseif strcmp(kernel, 'rbf')
            OPTIONS = optimset('MaxIter', 10000);
            OPTIONS = optimset(OPTIONS, 'UseParallel', 'always');
            svmModel{j} = svmtrain(features(idx,:), g(idx), ...
                'Method','QP', ...
                'options', OPTIONS,...
                'BoxConstraint',Inf,...
                'Kernel_Function', kernel,...
                'RBF_Sigma',kernel_param);
        end
        predTest(:,j) = svmclassify(svmModel{j}, features(pixels_testIdx,:));
        toc
        
        % catch ME
        %end
    end
    pred = mode(predTest,2);   %# voting: clasify as the class receiving most votes
    % Find the most frequent value of each column. (statistical mode)
    
    %# performance
    [cmat, order] = confusionmat(g(pixels_testIdx),pred);
    acc = 100*sum(diag(cmat))./sum(cmat(:));
    if debug
        fprintf('SVM (1-against-1):\naccuracy = %.2f%%\n', acc);
        fprintf('Confusion Matrix:\n'), disp(cmat)
        order
        gn
    end
    
    sum_accuracy = sum_accuracy + acc;
end

avg_accuracy = sum_accuracy / k;


end
