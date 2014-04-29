function [E,U] = PCOMMEND_Initialize(X,C,M,m)

% This function initialize
%   - U: the fuzzy membership matrix (CXN), and
%   - P:  Cell of C abundance matrices. One (NXM) matrix per cluster
% Input:
%   - X: Pixel points (NXd)
%   - C: Number of clusters
% output:
%   - P:  Cell of C abundance matrices. One (NXM) matrix per cluster,
%   - U1: the fuzzy membership matrix (CXN),


[Centers, U] = fcm(X, C, [2, 100, 1e-5, 0]);
[v L] = max(U);
for i = 1:C
    clear XX;
    XX = X(find(L == i), :);
    E{i} = XX(1:M,:);
end
