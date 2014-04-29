function [P2] = unmix3(data, endmembers, gammaConst, P, parameters)

%warning off all
%options = optimset('Display', 'off');

X = data;

% number of endmembers
% endmembers should be column vectors
M = size(endmembers, 2);

% number of pixels
N = size(X, 2);

% number of target classes
Nt = size(parameters.labels, 1);


gammaVecs = zeros(M,1);
for k = 2:M
    gammaVecs(k) = gammaConst/abs(sum(P(:,k)));
end
E = endmembers'; %endmembers as row vectors

P2 = zeros(N,M);

% find proportions at each pixel
for i = 1:N
    Xi = X(:,i);
    
    ll = true(M,1);
    ll(1:Nt) = (parameters.labels(:,i) == 1);
    
    % target endmembers
    et = E(ll,:);
    n_used = size(et,1);    
    
    TA = zeros(M,M); 
    TA(1:Nt, 1:Nt) = diag(2*parameters.beta.*parameters.labels(:,i));
    TA = TA(ll,ll);
    
    F1 = zeros(M,1);
    F1(1:Nt) = -2*parameters.beta;
    F1 = F1(ll);
    
    F = ((-2*Xi'*et')+gammaVecs(ll)')' + F1;
    H = (2*et*et') + TA;
            
    %set up constraint matrices
%     A1 = -1*eye(n_used);    
%     b1 = zeros(n_used, 1);
     
    A2 = ones(1, n_used);
    b2 = 1;
    
%     A3 = -1*ones(1, n_used);
%     b3 = -1;
%     A = [A1; A2; A3];
%     b = [b1; b2; b3];

    if parameters.sum_to_one
        L = [];
        k = [];
        A = A2;
        b = b2;
    else
        L = A2;
        k = b2;
        A = [];
        b = [];
    end
    
    l = zeros(n_used,1); % lower bound proportion of zero
    u = ones(n_used,1); % upper bound proportion of one
        
    %P2(i,ll) = quadprog(H, F, A, b, [], [], [], [], [], options);
    P2(i,ll) = qpas(H, F, L, k, A, b, l, u);
end

if(isnan(sum(sum(P2))) || isinf(sum(sum(P2))))
    keyboard;
end

