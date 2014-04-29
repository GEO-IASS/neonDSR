
function T=T_update(X,P,E,U,T, parameters)

% This function updates the typicality matrix (CXN).
% Input:
%   - X: Pixel points (NXd matrix).
%   - P:  Cell of C abundance matrices. One (NXM) matrix per cluster.
%   - E:  Cell of C endmembers matrices. One (MXd) matrix per cluster.
%   - U: the fuzzy membership matrix (CXN).
%   - m: Fuzzifier.
%   - EPS: small positive constant.
% Output:
%   - T: the typicality matrix (CXN).


N=size(X,1);
C=size(T,1);

RSS = zeros(C,N);
for i=1:C
    Y = (X - P{i}*E{i}).^2;
    RSS(i,:) = sum(Y,2);
end

%mm = mean(RSS(:));  % global mean RSS
mm = repmat(mean(RSS,2),1,N);  % class specific mean RSS
%mm = repmat((1./sum(U,2)).* sum(U.*RSS,2),1,N);  % class specific fuzzy mean RSS

T = 1./(1 + (parameters.b./mm).*RSS).^(1/(parameters.n -1));
