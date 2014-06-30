


figure
gscatter(meas(51:end,3), meas(51:end,4), species(51:end),'rgb','osd');
xlabel('petal length');
ylabel('petal width');

%====================================
figure
gscatter(meas(:,1), meas(:,2), species,'rgb','osd');
xlabel('Sepal length');
ylabel('Sepal width');
