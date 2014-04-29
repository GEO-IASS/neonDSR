
function [P2] = unmix4(data, endmembers, eps)
warning off all

options = optimset('Display', 'off');

%endmembers should be column vectors
X = data;

%number of endmembers
M = size(endmembers, 2);
%number of pixels
N = size(X, 2);

%set up constraint matrices
A1 = eye(M);
A1 = -1*A1;
b1 = zeros([M, 1]);

A2 = ones([1, M]);
b2 = 1+eps;

A3 = -1*ones([1, M]);
b3 = -(1+eps);


A = vertcat(A1, A2);
A = vertcat(A, A3);

b = vertcat(b1, b2);
b = vertcat(b, b3);

for i = 1:N
    %initial point
    %p = P(i,:);

    E = endmembers';
    Xi = X(:,i);

    F = (-2*Xi'*E')';
    H = (2*E*E');

    P2(i,:) = quadprog(H, F, A, b, [], [], [], [], [], options);
end

P2(P2<0) = 0;

