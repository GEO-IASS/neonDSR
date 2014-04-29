%% Random Legended multi-line plot code snippet  
x = 1 : 50;
y = rand(11,50); % 11 traces, 50 samples long
h = zeros(11,1); % initialize handles for 11 plots
figure;
h(1)=plot(x,y(1,:),'color',[rand(1),rand(1),rand(1)]); hold on;
for ii = 2 : 11
  h(ii)=plot(x,y(ii,:),'color',[rand(1),rand(1),rand(1)]);
end
hold off;
legend(h,'plot1','plot2','plot3','plot4','plot5','plot6','plot7',...
       'plot8','plot9','plot10','plot11');
  