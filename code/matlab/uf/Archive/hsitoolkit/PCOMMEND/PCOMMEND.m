function [E,P,U,obj_func]=PCOMMEND(X,parameters)

% This function computes mlti-model endmembers and their repesctive
% abundances
% Input:
%   - X: Pixel points (NXd matrix).
%   -parameters: The prameters set by MMICE_Parameters function.
% Output:
%   - E:  Cell of C endmembers matrices. One (MXd) matrix per cluster.
%   - P:  Cell of C abundance matrices. One (NXM) matrix per cluster.
%   - U: Fuzzy membership matrix (CXN).
%   - obj_func:  objective function value of the this iteration.

% Initialization
[E,U] = PCOMMEND_Initialize(X,parameters.C,parameters.M);
obj_func=inf;
for iter=1:parameters.iterationCap 
    %Update abundance
    %P=P_Update_PCOMM(X,E,parameters.C,parameters.EPS);
    P=P_update(X,E,parameters.C,parameters.EPS);
    
    %Update Endmembers
    E=E_Update_PCOMM(U,parameters.m,parameters.alpha,P,X, parameters.EPS);
    
    %Update fuzzy membership
    %U=U_Update_PCOMM( X,P,E,U,parameters.m,parameters.EPS);
    U=U_update( X,P,E,U,parameters.m,parameters.EPS);
    
    [Cond, obj_func]=Cond_update_PCOMM(obj_func,X,P,E,U,parameters.m);
    if(~mod(iter, 100))
        fprintf('iter= %d   Cond= %f\n', iter, Cond);
    end
    if(Cond <parameters.changeThresh)   
        break;
    end   
end


