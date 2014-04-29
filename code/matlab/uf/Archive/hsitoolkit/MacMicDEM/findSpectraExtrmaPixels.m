function [outputPixels, points] = findSpectraExtrmaPixels(inputData,M)

data = inputData;

N = size(inputData,2);
D = size(inputData,1);
extremaCount = zeros(N,1);

mu = mean(inputData, 2);
X = inputData - repmat(mu, 1, N);
dataCov = cov(X');
[V,Diag] = eig(dataCov);
diaD = diag(Diag);

numVD = 0;
for i=D:-1:1
    if sum(diaD(i:end))/sum(diaD) > .999
        numVD = i;
        break;
    end
end
numVD=numel(diaD) - M+2;
projMat = V(:,(end:-1:numVD));
stdDev = sqrt(diaD(end:-1:numVD));

data = projMat'*X;
data = data./repmat(stdDev, 1, N);
h=waitbar(0,'Please wait...');
for i=1:3*N
    waitbar( i/(3*N),h,[num2str(i), '/', num2str(3*N)]);
    skewer = rand(1,D-numVD + 1);
% skewer = rand(1,D);
    skewer = skewer./sum(skewer);
    projection = skewer*data;
    
    maxP = max(projection);
    minP = min(projection);
    
    extremaIndex = find(projection >= (maxP - maxP*.01));
    extremaCount(extremaIndex) = extremaCount(extremaIndex) + 1;
    
    extremaIndex = find(projection <= (minP + abs(minP*.01)));
    extremaCount(extremaIndex) = extremaCount(extremaIndex) + 1;
    
end
close(h);
extremPoints=find(extremaCount > 200);
oldDist = 0;
if M==2
for i=1:numel(extremPoints)
    for t=1:numel(extremPoints)
            newDist = dist(inputData(:,extremPoints(i))', inputData(:,extremPoints(t)));
            if newDist > oldDist
                oldDist = newDist;
                points = [extremPoints(i), extremPoints(t)];
            end
    end
end
end

if M==3
for i=1:numel(extremPoints)
    for t=1:numel(extremPoints)
         for z=1:numel(extremPoints)
            newDist = dist(inputData(:,extremPoints(i))', inputData(:,extremPoints(t))) + dist(inputData(:,extremPoints(t))', inputData(:,extremPoints(z)))+...
                dist(inputData(:,extremPoints(z))', inputData(:,extremPoints(i)));
            if newDist > oldDist
                oldDist = newDist;
                points = [extremPoints(i), extremPoints(t), extremPoints(z)];
            end
         end
    end
end
end

outputPixels = inputData(:, points);
end