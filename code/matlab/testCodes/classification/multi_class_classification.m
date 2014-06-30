

%Example multi-class
%# load dataset
load fisheriris
[g gn] = grp2idx(species);      %# nominal class to numeric (string classes to numeric)

%# split training/testing sets
[trainIdx testIdx] = crossvalind('HoldOut', species, 1/3);  % 0/1 specifying train or test

pairwise = nchoosek(1:length(gn),2);            %# 1-vs-1 pairwise models [1,2;1,3;2,3]
svmModel = cell(size(pairwise,1),1);            %# NchooseK binary-classifers: one classifier for each [1,2;1,3;2,3]
predTest = zeros(sum(testIdx),numel(svmModel)); %# binary predictions - three predictions per test (one for each classfier above)

%# classify using one-against-one approach, SVM with 3rd degree poly kernel
for k=1:numel(svmModel)
    %# get only training instances belonging to this pair
    idx = trainIdx & any( bsxfun(@eq, g, pairwise(k,:)) , 2 );

    %# train
    svmModel{k} = svmtrain(meas(idx,:), g(idx), ...
        'BoxConstraint',2e-1, 'Kernel_Function','polynomial', 'Polyorder',3);

    %# test
    predTest(:,k) = svmclassify(svmModel{k}, meas(testIdx,:));
end
pred = mode(predTest,2);   %# voting: clasify as the class receiving most votes
                           % Find the most frequent value of each column.

%# performance
cmat = confusionmat(g(testIdx),pred);
acc = 100*sum(diag(cmat))./sum(cmat(:));
fprintf('SVM (1-against-1):\naccuracy = %.2f%%\n', acc);
fprintf('Confusion Matrix:\n'), disp(cmat)