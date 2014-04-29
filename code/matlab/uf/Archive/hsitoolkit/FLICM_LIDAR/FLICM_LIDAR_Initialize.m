function [E,U,T] = FLICM_LIDAR_Initialize(X,parameters)

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

if ~isempty(parameters.init)
    E = parameters.init.E;
    U = parameters.init.U;
    T = parameters.init.T;
    return;
end

OPTIONS(1) = parameters.m;
OPTIONS(2) = 100;
OPTIONS(3) = 1e-5;
OPTIONS(4) = 0;

[Centers, U] = fcm(X, parameters.C, OPTIONS);
%D = dist(Centers, X');
D = pdist2(Centers,X);
T = 1./ (1+ (parameters.b*D.*D).^(1/(parameters.m-1)));

[v L] = max(U);
for i = 1:parameters.C
    clear XX;
    XX = X(find(L == i), :);
    %E{i} = XX(1:parameters.M,:);    
    E{i} = VCA(XX','Endmembers',parameters.M)';
end
