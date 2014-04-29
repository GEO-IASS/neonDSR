function [E,U] = PCOMMEND_Initialize(X,C,M)

% This function initialize
%   - U: the fuzzy membership matrix (CXN), and
%   - P:  Cell of C abundance matrices. One (NXM) matrix per cluster
% Input:
%   - X: Pixel points (NXd)
%   - C: Number of clusters
% output:
%   - P:  Cell of C abundance matrices. One (NXM) matrix per cluster,
%   - U1: the fuzzy membership matrix (CXN),


[~, U] = az_fcm(X', C);
[~, L] = max(U,[],1);
for i = 1:C
    clear XX;
    XX = X(L == i, :);
    if isempty(XX) || size(XX,1) < M
        N = size(X,1);
        rp = randperm(N);
        E{i} = X(1:M,:);
    else
        E{i} = XX(1:M,:);
    end
end
