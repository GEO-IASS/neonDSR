function [E,U,obj_func]=CA(X,parameters)

% 

%%
% Initialization
[E,U] = CA_Initialize(X, parameters.Cmax,parameters.M);
[N,d]=size(X); 
obj_func=inf;
C = parameters.Cmax;

for iter=1:parameters.iterationCap
    %Update Centers
    E=C_update(U,2,X);
    figure(101); plot(E'); pause(0.01);
    %Update fuzzy membership
    U=M_update(X,E,U,parameters.eta_0, parameters.tau, iter);

    %Compute Cardinality
    Ns = sum(U);
    if(sum(Ns < parameters.pruneThresh) > 0)
        %prune
        loc = find(Ns < parameters.pruneThresh);
        C = C - sum(Ns < parameters.pruneThresh);
        ii = setdiff([1:size(E,1)], loc);
        E = E(ii, :);
        U = U(:, ii);
    end
    [Cond, obj_func]=Cond_updateC(obj_func,X,E,U,2);
    if(Cond <parameters.changeThresh)   
        break;
    end   
end
