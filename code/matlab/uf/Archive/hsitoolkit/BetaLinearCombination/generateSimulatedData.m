function [X, psamples] = generateSimulatedData(Parameters)


%Sample Proportion Values

%Determine Data Point Group
groupSelection = mnrnd(1,Parameters.dgW,Parameters.N);
[~, groupSelection] = max(groupSelection, [], 2);
[psamples] = DirichletSample(Parameters.alpha(groupSelection,:));

%Generate Beta Values
E = zeros(Parameters.D, Parameters.N, Parameters.M);
for n = 1:Parameters.N
    for m = 1:Parameters.M
        E(:,n,m) = betarnd(Parameters.BetaParameters(:, 1, m), Parameters.BetaParameters(:, 2, m));
    end
    X(n,:,:) = repmat(squeeze(E(:,n,:))*psamples(n,:)', [1 Parameters.numNeighbor, 1]);
end

X = X + Parameters.noiseScale*randn(size(X));
X(X < 0) = 0;
X(X > 1) = 1;


end


function [psamples] = DirichletSample(A)        

Y        = randg(A) ; %Sample proportions under consideration
v        = sum(Y,2);
psamples = Y./repmat(v, [1, size(A,2)]);

end
