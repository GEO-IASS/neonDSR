function accuracy = svmMultiClass(classes, features, debug)
%% This is a single run of SVM with 2/3 vs 1/3 partitioing of data

%Example multi-class
[g gn] = grp2idx(classes);      %# nominal class to numeric (string classes to numeric)

%# split training/testing sets
[trainIdx testIdx] = crossvalind('HoldOut', classes, 1/3);  % 0/1 specifying train or test

pairwise = nchoosek(1:length(gn),2);            %# 1-vs-1 pairwise models [1,2;1,3;2,3]
svmModel = cell(size(pairwise,1),1);            %# NchooseK binary-classifers: one classifier for each [1,2;1,3;2,3]
predTest = zeros(sum(testIdx),numel(svmModel)); %# binary predictions - three predictions per test (one for each classfier above)

%# classify using one-against-one approach, SVM with 3rd degree poly kernel
for k=1:numel(svmModel)
    %# get only training instances belonging to this pair
    selector = any( bsxfun(@eq, g, pairwise(k,:)) , 2 );
    idx = trainIdx & selector;

    %# train
    svmModel{k} = svmtrain(features(idx,:), g(idx), ...
        'BoxConstraint',2e-1, 'Kernel_Function','polynomial', 'Polyorder',1);

    %# test
    predTest(:,k) = svmclassify(svmModel{k}, features(testIdx,:));
end
pred = mode(predTest,2);   %# voting: clasify as the class receiving most votes
                           % Find the most frequent value of each column.

%# performance
[cmat, order] = confusionmat(g(testIdx),pred);
accuracy = 100*sum(diag(cmat))./sum(cmat(:));

if debug 
  fprintf('SVM (1-against-1):\naccuracy = %.2f%%\n', accuracy);
  fprintf('Confusion Matrix:\n'), disp(cmat)
  order
  gn
end



end




