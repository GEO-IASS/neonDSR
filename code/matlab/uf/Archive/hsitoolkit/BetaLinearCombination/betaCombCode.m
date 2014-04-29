function [KLDiv, p, q] = betaCombCode(Parameters)


%Generate Proportions
[psamples] = DirichletSample(Parameters.N, Parameters.alpha);


%Method 1 - Linear Combination of Betas
%Generate Beta Values
E = zeros(Parameters.N, Parameters.M);
for m = 1:Parameters.M
 E(:,m) = betarnd(Parameters.BetaA(m), Parameters.BetaB(m), [Parameters.N, 1]);
end
X =sum(E.*psamples,2);
if(Parameters.display)
figure; subplot(2,1,1); 
end
h1 = hist(X, Parameters.histBins); 
if(Parameters.display)
    bar(Parameters.histBins, h1);
    title('Linear Combination of Betas');
end

%Method 2 - Approximation 1
Parameters.rho = 1;
e = Parameters.BetaA ./ (Parameters.BetaA + Parameters.BetaB);
v = (Parameters.BetaA.*Parameters.BetaB)./ (((Parameters.BetaA + Parameters.BetaB).^2).*(Parameters.BetaA + Parameters.BetaB + 1));
E = sum(psamples.* repmat(e, [Parameters.N, 1]),2);
F = E./(1- E);
S = 1/(Parameters.rho^2)*sum( (psamples.^2).*repmat(v, [Parameters.N, 1]), 2);
f = F ./ (S.*((1+F).^3)) - 1./(1 + F);
e = F.*f;
X = betarnd(e, f);
h2 = hist(X, Parameters.histBins); 
if(Parameters.display)
    subplot(2,1,2); bar(Parameters.histBins, h2); 
    title('Approximation Method');
end

%Method 3 - Approximation 2
%skew = (2*(Parameters.BetaB - Parameters.BetaA).*sqrt(Parameters.BetaA + Parameters.BetaB +1))./((Parameters.BetaA + Parameters.BetaB + 2).*sqrt(Parameters.BetaA.*Parameters.BetaB));

%Compare Results
p = h1 / Parameters.N;
q = h2 / Parameters.N;
KLDiv = sum( log((p+eps)./(q+eps)) .* p) + sum( log((q+eps)./(p+eps)) .* q);

end


function [psamples] = DirichletSample(NPts, AlphaVector)        


A        = repmat(AlphaVector, [NPts, 1]);
Y        = randg(A) ; %Sample proportions under consideration
v        = sum(Y,2);
psamples = Y./repmat(v, [1, size(A,2)]);
end