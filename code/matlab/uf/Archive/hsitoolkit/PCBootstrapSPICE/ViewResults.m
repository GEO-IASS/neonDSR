function ViewResults(E, C)

NumParts = length(E);

for i = 1:NumParts
    numE = size(E{i},1);
    figure(100+i); 
    for j = 1:numE
        subplot(2, ceil(numE/2), j);
        errorbar(E{i}(j,:), diag(C{i}(:,:,j)),  'linewidth', 2);
    end
end

