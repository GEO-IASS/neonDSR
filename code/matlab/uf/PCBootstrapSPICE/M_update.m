function U=M_update(X,E,U,eta_0, tau, iteration)

% This function updates the fuzzy membership matrix (CXN).
% Input:
%   - X: Pixel points (NXd matrix).
%   - P:  Cell of C abundance matrices. One (NXM) matrix per cluster.
%   - E:  Cell of C endmembers matrices. One (MXd) matrix per cluster.
%   - U: the fuzzy membership matrix (CXN).
%   - m: Fuzzifier.
%   - EPS: small positive constant.
% Output:
%   - U: the fuzzy membership matrix (CXN).


N=size(X,1);
C=size(U,2);
EPS=1e-40;
for i=1:C
    Y = (X - repmat(E(i,:), [N, 1]));
    Dist(i,:) = sum((Y.*Y)')';
end

eta = eta_0*exp(-iteration/tau);
alpha = eta*(sum(sum((U'.^2).*Dist))/sum((sum(U).^2)));
%alpha = eta_0;
%figure(100);
%scatter(iteration, alpha, 20, 'r'); hold on;


Dist_1=1./(((Dist+EPS))+EPS);
S = sum(Dist_1);
Ufcm = (Dist_1)./repmat(S, [C,1]);

Ns = sum(U);
Nt = sum(Dist_1.*repmat(Ns', [1, N]))./sum(Dist_1);
Diff = repmat(Ns', [1, N])-repmat(Nt, [C, 1]);
Ubias = alpha*Diff./(Dist+EPS);

U = Ufcm + Ubias;
U = U';