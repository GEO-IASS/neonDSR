function E=E_update(U,T,P,X,parameters)

% This function updates the endmembers matrices (one per cluster)
% Input:
%   - U: Fuzzy membership matrix (CXN). 
%   - P:  Cell of C abundance matrices. One (NXM) matrix per cluster.
%   - X: Pixel points (NXd matrix).
% Output:
%   - E:  Cell of C endmembers matrices. One (MXd) matrix per cluster

C=length(P);
N=size(X,1);
M=size(P{1},2);
DP=parameters.EPS*eye(M,M);
Lmda=N*(parameters.alpha)/((M-1)*(1-parameters.alpha));
Z = Lmda*(eye(M,M)-(1/M)*ones(M,M));
for i=1:C
        Y = (repmat((parameters.a*(U(i,:).^parameters.m) + parameters.b*(T(i,:).^parameters.n))', [1 M]).*P{i})';
        E{i}=inv((Y*P{i}+DP) + Z)*Y*X;
end