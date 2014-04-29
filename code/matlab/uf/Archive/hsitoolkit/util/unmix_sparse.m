function [P2] = unmix_sparse(data, endmembers, parameters)
%function [P2] = unmix_sparse(data, endmembers, parameters)
%
% do a sparse unmixing of the data using the given endmembers
% ie, the unmixing may be ambiguous, so iterate to find a sparser solution
% (though not necessarily the unique sparsest solution...
%   probably it depends on quadprog/qpas's initialization)


%endmembers should be column vectors
X = data;

%number of endmembers
M = size(endmembers, 2);
%number of pixels
N = size(X, 2);


A2 = ones(1, M);  % sum to one
b2 = 1;

l = zeros(M,1);
u = ones(M,1);

P2 = zeros(N,M);

E = endmembers';

e = 0.01;

for i = 1:N
        
    x_i = X(:,i);

    mag = norm(x_i);
        
    em_inds = true(1,M);
    em_old = em_inds;

    p = [];
    for j=1:M-1    
        E_sp = E(em_inds,:);
        
        H = (2*E_sp*E_sp');
        F = (-2*x_i'*E_sp')';
        %set up constraint matrices
        if parameters.sum_to_one
            L = [];
            k = [];
            A = A2(em_inds);
            b = b2;
        else
            % sum to less than or equal 1
            L = A2(em_inds);
            k = b2;
            A = [];
            b = [];
        end

        qp_out = qpas(H, F, L, k, A, b, l(em_inds), u(em_inds));
        
        err = norm(x_i - E_sp'*qp_out);
        if err < e*mag
            em_old = em_inds;
            [~,min_p_ind] = min(qp_out);
            em_inds(min_p_ind) = false;
            p = qp_out;
        else
            if isempty(p), p = qp_out; end
            break;
        end
    end
    
    P2(i,em_old) = p;
    
end

P2(P2<0) = 0;

