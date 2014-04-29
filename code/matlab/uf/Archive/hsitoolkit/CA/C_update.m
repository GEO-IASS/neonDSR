function E=C_update(U,m,X)

% This function updates the endmembers matrices (one per cluster)
% Input:
%   - U: Fuzzy membership matrix (CXN). 
%   - m: Fuzzifier.
%   - X: Pixel points (NXd matrix).
% Output:
%   - E:  Cell of C endmembers matrices. One (MXd) matrix per cluster

C=size(U,2);
N=size(X,1);
D = size(X,2);


E = ((U.^m)'*X)./repmat(sum((U.^m))', [1, D]);

