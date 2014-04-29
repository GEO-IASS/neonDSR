function [P2] = unmix2(data, endmembers, parameters)

%endmembers should be column vectors
X = data;

%number of endmembers
M = size(endmembers, 2);
%number of pixels
N = size(X, 2);

A1 = -1*eye(M);     % positivity
b1 = zeros([M, 1]);

A2 = ones([1, M]);  % sum to one
b2 = 1;

A3 = -1*ones([1, M]); % ?? negative sums to -1
b3 = -1;


%set up constraint matrices
if parameters.sum_to_one

    L = [];
    k = [];
    
    A = A2;
    b = b2;
else
    % sum to less than or equal 1
    L = A2;
    k = b2;
    
    A = [];
    b = [];
end


l = zeros(M,1);
u = ones(M,1);

P2 = zeros(N,M);

E = endmembers';
H = (2*E*E');

for i = 1:N

    Xi = X(:,i);

    F = (-2*Xi'*E')';

    P2(i,:) = qpas(H, F, L, k, A, b, l, u);
end

P2(P2<0) = 0;

