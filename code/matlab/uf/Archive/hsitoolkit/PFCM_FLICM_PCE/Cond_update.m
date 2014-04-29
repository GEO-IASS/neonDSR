function [Cond, obj_func]=Cond_update(obj_func_old,X,P,E,U,T,parameters)
% This function computes the stopping criteria
% Input
%   - obj_fun_old:  objective function value of the precedent iteration.
%   - X: Pixel points (NXd matrix).
%   - P:  Cell of C abundance matrices. One (NXM) matrix per cluster.
%   - E:  Cell of C abundance matrices. One (MXd) matrix per cluster.
%   - U: Fuzzy membership matrix (CXN). 
%   - m: Fuzzifier.
% Output:
%   - obj_func:  objective function value of the this iteration.
%   -Cond: The stopping criteria

C=size(U,1);
U=U.^parameters.m;
obj_func=0;

for i=1:C
    Y = (X - P{i}*E{i}).^2;
    D = sum(Y,2);
    obj_func = obj_func+sum((parameters.alpha*T(i,:)' + parameters.alpha*U(i,:)').*D);
end


Cond=abs(obj_func - obj_func_old);