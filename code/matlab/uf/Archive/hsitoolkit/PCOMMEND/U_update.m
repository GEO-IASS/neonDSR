function U=U_update(X,P,E,U,m,EPS)

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
C=size(U,1);
EPS=1e-40;
Dist = zeros(C,N);
for i=1:C
    Y = (X - P{i}*E{i}).^2;
    Dist(i,:) = sum(Y,2);
end
%M2 = (1.-U).^m;
% G2 = reshape(shiftdim(M2.*Dist,1), size(InputImage,1), size(InputImage,2), C);
% for i = 1:C
%     G(:,:,i) = conv2(G2(:,:,i), dM, 'same');
% end
% G = reshapeImage(G)';

%Dist_1=1./(((Dist+G'+EPS).^(1/(m-1)))+EPS);
Dist_1=1./(((Dist+EPS).^(1/(m-1)))+EPS);

S = sum(Dist_1);
U = (Dist_1)./repmat(S, [C,1]);


% for k=1:N
%     S(k)=sum(Dist_1(:,k));
%     for i=1:C
%         U(i,k)=Dist_1(i,k)*(1/(S(k)+EPS));
%     end
% end
