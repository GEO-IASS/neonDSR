function E=E_update(U1,m,alpha,P,X,EPS)

% This function updates the endmembers matrices (one per cluster)
% Input:
%   - U: Fuzzy membership matrix (CXN). 
%   - m: Fuzzifier.
%   -alpha : Regularization Parameter to trade off between the RSS and V
%   terms
%   - P:  Cell of C abundance matrices. One (NXM) matrix per cluster.
%   - X: Pixel points (NXd matrix).
% Output:
%   - E:  Cell of C endmembers matrices. One (MXd) matrix per cluster

C=length(P);
N=size(X,1);
M=size(P{1},2);
DP=EPS*eye(M,M);
Lmda=N*alpha/((M-1)*(1-alpha));
Z = Lmda*(eye(M,M)-(1/M)*ones(M,M));
for i=1:C
        Y = (repmat((U1(i,:).^m)', [1 M]).*P{i})';
        E{i}=inv((Y*P{i}+DP) + Z)*Y*X;
end