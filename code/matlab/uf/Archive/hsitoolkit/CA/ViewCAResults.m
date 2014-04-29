function ViewCAResults(C, U, X)

numC = size(C, 1);
numBins = 255;
numPts = size(X,1);
figNumStart = 100;

cM = colormap(hot(numBins));
cM = flipud(cM);

for i = 1:numC;
    hold off;
    figure(figNumStart+i-1);
    binSel = max(min(round(U(:,i)*numBins), numBins), 1);
    [~, loc] = sort(binSel);
    for j = loc'
        plot(X(j,:), 'linewidth', 2, 'Color', cM(binSel(j),:));
        hold on;
    end
    plot(C(i,:), 'c', 'linewidth', 3);
end