function [P] = ncmProportionEstimate(X, E, C)

% Estimate proportion values using the Normal Compositional Model
% given endmember distributions and input data
%
% Syntax: [P] = ncmProportionEstimate(X, E, C)
%
% Inputs:
%   X - NxD matrix of N data points of
%       dimensionality D (i.e.  N pixels with D spectral bands, each pixel is
%       a row vector)
%   E - MxD matrix of M endmember means of dimensionality D (each endmember
%       is a row vector)
%   C - MxD matrix (each row is the diagonal of a diagonal covariance
%       matrix)
%
% Outputs:
%   P - NxM matrix of abundances corresponding to M input
%       pixels and N endmembers
%
% Author: Alina Zare
% University of Missouri, Electrical and Computer Engineering Department
% Email Address: zarea@missouri.edu
% Created: February 24, 2012
% Latest Revision: February 24, 2012
%
% This product is Copyright (c) 2012 Alina Zare, Paul Gader.
% All rights reserved.
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions
% are met:
%
%   1. Redistributions of source code must retain the above copyright
%      notice, this list of conditions and the following disclaimer.
%   2. Redistributions in binary form must reproduce the above copyright
%      notice, this list of conditions and the following disclaimer in the
%      documentation and/or other materials provided with the distribution.
%   3. Neither the name of the University nor the names of its contributors
%      may be used to endorse or promote products derived from this software
%      without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE UNIVERSITY OF MISSOURI AND
% CONTRIBUTORS ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED.  IN NO EVENT SHALL THE UNIVERSITY OR CONTRIBUTORS
% BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES,
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
% OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


%%
% Parameter Settings
numIterations   = 20000;
[N, D]          = size(X);
M               = size(E,1);
onesLengthAlpha = ones(1, M);
scale           = 2;
diagFlag        = 1;

%Sampling Method

if(diagFlag)
    for i = 1:M
        CC(1,:,i) = C(i,:);
    end
    CC = repmat(CC, [N, 1, 1]);
    
    %Initialize P
    P       = DirichletSample(N, ones(1,M));
    Lbest   = ComputeLogLikelihoodAllD(X, E, P, CC, N, M, D);
    Pbest   = P;
    LogLikelihoodOld = Lbest;
    
    for i = 1:numIterations
        if(mod(i,5) == 0);
            disp(['Iteration ', num2str(i), ' of ', num2str(numIterations)]);
        end
        
        Y                     = randg(1, N, M) ; %Sample proportions under consideration
        v                     = sum(Y,2);
        samples               = Y./v(:, onesLengthAlpha);
        LogLikelihoodNew      = ComputeLogLikelihoodAllD(X, E, samples, CC, N, M, D);
        Ratios                = exp((LogLikelihoodNew) - (LogLikelihoodOld));
        rands                 = rand(N,1);
        Vals                  = rands < Ratios;
        Vrep                  = Vals(:, onesLengthAlpha);
        P                     = samples.*Vrep  + P.*(1-Vrep);
        LogLikelihoodOld      = (1-Vals).*LogLikelihoodOld + (Vals).*LogLikelihoodNew;
        
        Vals                  = exp(Lbest) < exp(LogLikelihoodOld);
        Vrep                  = Vals(:, onesLengthAlpha);
        Lbest                 = Vals.*LogLikelihoodOld + (1-Vals).*Lbest;
        Pbest                 = Vrep.*P + (1-Vrep).*Pbest;
    end
    
    
else
    
    %Repmat C
    for i = 1:M
        CC{i} = repmat(C(:,:,i), [1, 1, N]);
    end
    
    %Initialize P
    P       = DirichletSample(N, ones(1,M));
    Lbest   = ComputeLogLikelihoodAll(X, E, P, CC, N, M, D);
    Pbest   = P;
    LogLikelihoodOld = Lbest;
    
    for i = 1:numIterations
        if(mod(i,5) == 0);
            disp(['Iteration ', num2str(i), ' of ', num2str(numIterations)]);
        end
        
        Y                     = randg(1, N, M) ; %Sample proportions under consideration
        v                     = sum(Y,2);
        samples               = Y./v(:, onesLengthAlpha);
        %samples               = DirichletSample(N, scale*P);
        LogLikelihoodNew      = ComputeLogLikelihoodAll(X, E, samples, CC, N, M, D);
        %PriorNew              = evaluateDirichlet(samples, scale*P);
        %PriorOld              = evaluateDirichlet(P, scale*samples);
        %Ratios                = exp((LogLikelihoodNew + PriorOld) - (LogLikelihoodOld + PriorNew));
        Ratios                = exp((LogLikelihoodNew) - (LogLikelihoodOld));
        rands                 = rand(N,1);
        %disp(['Old: ', num2str((X(1,:)-P(1,:)*E)*(X(1,:)-P(1,:)*E)'), ' New: ', num2str((X(1,:)-samples(1,:)*E)*(X(1,:)-samples(1,:)*E)'), ' Ratio: ', num2str(Ratios(1)), ' Rand: ', num2str(rands(1))]);
        Vals                  = rands < Ratios;
        Vrep                  = Vals(:, onesLengthAlpha);
        P                     = samples.*Vrep  + P.*(1-Vrep);
        LogLikelihoodOld      = (1-Vals).*LogLikelihoodOld + (Vals).*LogLikelihoodNew;
        
        Vals                  = exp(Lbest) < exp(LogLikelihoodOld);
        Vrep                  = Vals(:, onesLengthAlpha);
        Lbest                 = Vals.*LogLikelihoodOld + (1-Vals).*Lbest;
        Pbest                 = Vrep.*P + (1-Vrep).*Pbest;
    end
end
P = Pbest;

end


%%
% Helper Functions are here.
function [psamples] = DirichletSample(NPts, AlphaVector)
%Sample from a Dirichlet Distribution
if(size(AlphaVector, 1) == 1)
    A        = repmat(AlphaVector, [NPts, 1]);
else
    A = AlphaVector;
end
Y        = randg(A) ;
v        = sum(Y,2);
psamples = Y./repmat(v, [1, size(A,2)]);
end

function [value] = evaluateDirichlet(samples, alphaVec)

B = prod(gamma(alphaVec), 2) ./ gamma(sum(alphaVec, 2));
B = 1./B;

value = B.*prod(samples.^(alphaVec-1), 2);


end

function [LogLikelihoodAll] = ComputeLogLikelihoodAll(X, E, P, CC, NumPoints, M, D)
LogLikelihoodAll = zeros(NumPoints, 1);
Recon = P*E;
diff  = (X - Recon)';
c = zeros(D, D, NumPoints);
PP = P.*P;
for j = 1:M
    clear z;
    z(1,1,:) = PP(:,j);
    z = repmat(z, [D,D,1]);
    c = c + z.*CC{j};
end

for i = 1:NumPoints
    [L,U] = lu(c(:,:,i));
    detC = prod(diag(L))*prod(diag(U));
    LogLikelihoodAll(i) =  (-1/2)*log(detC) + (-1/2)*diff(:,i)'*inv(c(:,:,i))*diff(:,i);
end
end


function [LogLikelihoodAll] = ComputeLogLikelihoodAllD(X, E, P, CC, NumPoints, M, D)
LogLikelihoodAll = zeros(NumPoints, 1);
Recon = P*E;
diff  = (X - Recon)';
c = zeros(NumPoints, D);
PP = P.*P;

A = bsxfun(@times,PP,permute(CC,[1,3,2]));
c = squeeze(sum(A,2))';
LogLikelihoodAll =  (-1/2)*log(prod(c,1)) + (-1/2)*sum(diff.*diff.*(1./c),1);
LogLikelihoodAll = LogLikelihoodAll';
end
