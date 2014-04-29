function U=U_update(img,mask,X,P,E,U,m,EPS,dM)

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
RSS = zeros(C,N);
for i=1:C
    Y = (X - P{i}*E{i}).^2;
    RSS(i,:) = sum(Y,2);
end
M2 = (1.-U).^m;

[n_row,n_col,n_band] = size(img);
n_pix = n_row*n_col;

tmp = zeros(C,n_pix);  
tmp(:,mask(:)) = M2.*RSS; % expand with zeros for invalid pixel vals

G2 = reshape(tmp', n_row, n_col, C);

G = zeros(n_row,n_col,C);

for i = 1:C
    G(:,:,i) = conv2(G2(:,:,i), dM, 'same');
    % this convolution uses zero values at invalid pixel locations
    %  i dont know if this is a reasonable thing to do... have not thought enough about it
end
G = reshapeImage(G)';

G(~mask(:),:) = []; % remove invalid pixel vals

Dist_1=1./( ( (RSS+G'+EPS).^(1/(m-1)) ) + EPS );
%Dist_1=1./(((RSS+EPS).^(1/(m-1)))+EPS);

S = sum(Dist_1);
U = (Dist_1)./repmat(S, [C,1]);

