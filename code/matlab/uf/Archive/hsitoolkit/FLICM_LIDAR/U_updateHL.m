function U=U_updateHL(InputImage, X,P,E,U,m,EPS, dM)

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
NRows = size(InputImage,1);
NCols = size(InputImage,2);
EPS=1e-40;
NghdSize = size(dM{1},1);
center   = ceil(NghdSize/2);
SRow     = center;
ERow     = NRows - center + 1;
SCol     = center;
ECol     = NCols - center + 1;

for i=1:C
    Y = (X - P{i}*E{i});
    Dist(i,:) = sum((Y.*Y)')';
end
M2 = (1.-U).^m;
G2 = reshape(shiftdim(M2.*Dist,1), nRows, nCols, C);
for i = 1:C
    for r = SRow:ERow
        for c = SCol:ECol
            G(r,c,i) = sum(sum(G2(r-center+1:r+center+1, c-center+1:c+center-1,i).*dM{r,c}));
        end
    end
end
G = reshapeImage(G)';

Dist_1=1./(((Dist+G'+EPS).^(1/(m-1)))+EPS);


S = sum(Dist_1);
U = (Dist_1)./repmat(S, [C,1]);