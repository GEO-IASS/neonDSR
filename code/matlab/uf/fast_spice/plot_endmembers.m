function plot_endmembers(E,X,figbase)

if ~exist('figbase','var'), figbase = 100; end

n_pix = size(X,2);

if n_pix > 5000
    stride = 10;
else
    stride = 1;
end

[y,~,vecs,~,mu] = pca(X,1);

EE = vecs'*(E - repmat(mu, [1, size(E,2)]));
figure(figbase);
hold off;
scatter3(y(1,1:stride:end), y(2,1:stride:end), y(3,1:stride:end));
hold on;
%scatter3(EE(1,:), EE(2,:), EE(3,:), 100, 'k', 'filled');
for i=1:size(EE,2)
   text(EE(1,i),EE(2,i),EE(3,i),num2str(i),'BackgroundColor',[0 0 0],'Color',[1 1 1]);
end

title('Scatter Plot of Endmembers');


figure(figbase+1);
plot(E);
ylim([min(0,min(E(:))),max(1,max(E(:)))]);
title('Endmembers');

figure(figbase+2);
hold off;
scatter(y(1,:), y(2,:));
hold on;
scatter(EE(1,:), EE(2,:), 100, 'k', 'filled');
for i=1:size(EE,2)
   text(EE(1,i),EE(2,i),num2str(i),'BackgroundColor',[0 0 0],'Color',[1 1 1]);
end

title('Scatter Plot of Endmembers');
