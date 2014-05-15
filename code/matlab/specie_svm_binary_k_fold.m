function avg_accuracy = specie_svm_binary_k_fold(classes, features, debug, polynomial_order)
%% This is a k-fold classification all-vs-all (as compared to one-vs-all)

if nargin < 1
  debug = 0;
  polynomial_order = 1;
end

[g gn] = grp2idx(classes);      %# nominal class to numeric (string classes to numeric)

k=10;
sum_accuracy = 0;
cvFolds = crossvalind('Kfold', classes, k);   %# get indices of 10-fold CV

for i = 1:k                                  %# for each fold
    testIdx = (cvFolds == i);                %# get indices of test instances
    trainIdx = ~testIdx;                     %# get indices training instances
             
    pairwise = nchoosek(1:length(gn),2);            %# all-vs-all pairwise models [1,2;1,3;2,3]
    svmModel = cell(size(pairwise,1),1);            %# NchooseK binary-classifers: one classifier for each [1,2;1,3;2,3]
    predTest = zeros(sum(testIdx),numel(svmModel)); %# binary predictions - three predictions per test (one for each classfier above)

    %# classify using one-against-one approach
    for j=1:numel(svmModel)
        %# get only training instances belonging to this pair
        selector = any( bsxfun(@eq, g, pairwise(j,:)) , 2 );
        idx = trainIdx & selector;

        % train - test
        try
           % svmModel{j} = svmtrain(meas(idx,:), g(idx), ...
           %    'BoxConstraint',2e-1, 'Kernel_Function','polynomial', 'Polyorder',polynomial_order);         
         
           svmModel{j} = svmtrain(features(idx,:), g(idx), ...
              'Method','QP', ...
              'BoxConstraint',Inf, 'Kernel_Function','rbf', 'RBF_Sigma',polynomial_order);
         
          predTest(:,j) = svmclassify(svmModel{j}, features(testIdx,:));

        catch ME
        end
    end
    pred = mode(predTest,2);   %# voting: clasify as the class receiving most votes
                           % Find the most frequent value of each column.

    %# performance
    [cmat, order] = confusionmat(g(testIdx),pred);
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
