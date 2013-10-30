function [endmembersNew] = spice_solve_endmembers(X, endmembers, P, parameters)
 
%endmembers should be column vectors
%X = data;

%number of endmembers
M = size(endmembers, 2);

N_pixels = size(X,2);
N_bands = size(endmembers, 1);

Im = eye(M);

lambda = N_pixels*parameters.u/((M-1)*(1-parameters.u));
He = P'*P + lambda*(Im - ones(M,M)/M);

if lambda ==0
    %keyboard
    loadingElement = eps*ones(M, 1);
    diagLoad = diag(loadingElement );
    He = He + diagLoad;
end

fe = -(P'*X');

%Boundary Constraints lb >= x >= ub
%All values must be greater than 0 (0 ? X1,0 ? X2,...,0 ? XM)
lb = zeros([M, 1]);
ub = ones([M,1]);
 
endmembersNew = zeros(size(endmembers));

for i = 1:N_bands
    endmembersNew(i, :) = qpas(He, fe(:, i), [], [], [], [], lb, ub, 0);
end
