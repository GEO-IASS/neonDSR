
figure(1)

load fisheriris
xdata = meas(51:end,3:4);
group = species(51:end);
svmStruct = svmtrain(xdata,group,'ShowPlot',true);

% Classify a new flower with petal length 5 and petal width 2, and circle the new point:

classified_specie = svmclassify(svmStruct,[5 2],'ShowPlot',true)
hold on;
plot(5,2,'ro','MarkerSize',12);
hold off
