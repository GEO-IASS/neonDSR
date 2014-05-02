
load('hospital')

stats = grpstats(hospital,'Sex',{'min','max'},'DataVars','Weight')

stats = grpstats(hospital,{'Sex','Smoker'},{'min','max'},...
                 'DataVars','Weight')
%

load('carsmall')

Origin = nominal(Origin);
getlevels(Origin)

      

figure()
boxplot(Acceleration,Origin)
title('Acceleration, Grouped by Country of Origin')

tabulate(Origin)