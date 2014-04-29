function [Y, T, Errors] = pcaInvert(X)

resultingDim = 10;
[Npts, Dim] = size(X);
mu = mean(X);

Xbar = X - repmat(mu, [Npts, 1]);
C = cov(Xbar);
[V,D] = eig(C);
[~, loc] = sort(diag(D), 1, 'descend');
locKeep = loc(1:resultingDim);
T = V(:, locKeep);

Y = Xbar*T;

%Now invert and compute errors
Xinv = (Y*pinv(T)) + repmat(mu, [Npts, 1]);
Errors = X - Xinv;