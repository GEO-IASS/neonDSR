

% 10-fold cross-validation on the fisheriris data using linear
% discriminant analysis and the third column as only feature for
% classification
load fisheriris
% 1 2 3 4
%sepal width/length petal width/length

indices = crossvalind('Kfold',species,10);
cp = classperf(species); % initializes the CP object
for i = 1:10
    test = (indices == i); train = ~test;
    class = classify(meas(test,3),meas(train,3),species(train));
    % updates the CP object with the current classification results
    classperf(cp,class,test)  
end

disp('------------------------------------');
disp('Correct rate / Error rate:')

cp.CorrectRate % queries for the correct classification rate

cp.ErrorRate
