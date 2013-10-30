function [X, P] = generateData(E, NumPoints)

C = length(E);

for i = 1:C
    numE(i) = size(E{i},1);
end
X = zeros(NumPoints*C, size(E{1},2));


for c = 1:C
    estart = sum(numE(1:c-1)+1);
    if(c == 1)
        estart = 1;
    end
    for i = 1:NumPoints
        
        %Select Number of Endmembers
        r = find(mnrnd(1,ones(1,numE(c))*(1/numE(c))));
        
        %Select Endmembers
        rp = randperm(numE(c));
        r = rp(1:r);
        
        %generate proportions
        alpha = zeros(1,numE(c));
        alpha(r) = 1;
        [psamples] = DirichletSample(1, alpha);
        P((c-1)*NumPoints + i,estart:estart+numE(c)-1) = psamples;
        
        
        X((c-1)*NumPoints + i,:) = psamples*E{c};
        
    end
end


