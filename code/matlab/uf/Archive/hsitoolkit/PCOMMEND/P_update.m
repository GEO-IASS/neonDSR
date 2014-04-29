function P=P_update(X,E,C,EPS)

% This function updates the abundace matrices (one per cluster)
% Input:
%   - X: Pixel points (NXd matrix).
%   - E:  Cell of C endmembers matrices. One (MXd) matrix per cluster.
%   - M:  Number of endmembers.
%   - EPS: Small positive constant.
% Output:
%   - P:  Cell of C abundance matrices. One (NXM) matrix per cluster



for i=1:C
    P{i} = getProps(E{i}, X, EPS);
end

end


function [P] = getProps(E, X, EPS)

M=size(E,1);
DP=EPS*eye(M,M);
N=size(X,1);

if(M > 1)
    
    % P update
    Y = inv((E*(E)')+ DP);
    Z = ones(1,M)*Y;
    Lamda=(1-(Z*E*(X)'))/(Z*ones(M,1));
    P=(Y*(E*(X)'+ (Lamda'*ones(M,1)')'))';
    Z = P < 0;
    if(sum(sum(Z)) > 0)
        ZZ = unique(Z, 'rows', 'first');
        for i = 1:size(ZZ, 1)
            if(sum(ZZ(i,:)) > 0)
                eLocs = find(1 - ZZ(i,:));
                
                rZZi = repmat(ZZ(i,:),N,1);
                inds = all(Z == rZZi,2);                
                [Ptemp] = getProps(E(eLocs,:), X(inds,:), EPS);                
                Ptemp2 = zeros(sum(inds), size(ZZ,2));
                
                Ptemp2(:, eLocs) = Ptemp;
                P(inds,:) = Ptemp2;
            end
        end
    end
else
    P = ones(size(X,1), 1);
end

end