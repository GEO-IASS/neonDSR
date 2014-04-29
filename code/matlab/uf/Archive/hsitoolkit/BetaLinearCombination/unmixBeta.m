function [P, F, E, S] = unmixBeta(Xim, Parameters, F, E, S)

Xlist = reshape(Xim, [size(Xim,1)*size(Xim,2), size(Xim,3)]);
dists = pdist2(Xlist, Xlist);
for i = 1:size(Xim,1)*size(Xim,2)
    [~, s] = sort(dists(i,:));
    X(i,:,:) = Xlist(s(1:Parameters.K), :)';
end
Parameters.N = size(X,1);


%metropolis-hastings algorithm
for m = 1:Parameters.M
    M(:,m) = Parameters.BetaParameters(:,1,m)./(Parameters.BetaParameters(:,1,m) + Parameters.BetaParameters(:,2,m));
    if(Parameters.methodFlag == 2)
        V(:,m) = (Parameters.BetaParameters(:,1,m).*Parameters.BetaParameters(:,2,m))./(((Parameters.BetaParameters(:,1,m)+Parameters.BetaParameters(:,2,m)).^2).*(Parameters.BetaParameters(:,1,m)+Parameters.BetaParameters(:,2,m)+1));
    end
end

if(nargin < 3)
    for n = 1:size(X, 1)
        %first, estimate e and f from data.
        for d = 1:Parameters.D
            ef(d,:) = betafit(squeeze(X(n,d,:)));
        end
        
        F(n,:) = ef(:,1)./ef(:,2);
        E(n,:) = 1./(1./F(n,:) + 1);
        S(n,:) = (ef(:,2)' + 1./(1 + F(n,:))).*(((1-F(n,:)).^3)./F(n,:));
        
        n
    end
end
    

if(Parameters.methodFlag == 1)
    
    P = unmix_qpas_correct(E', M);
    
elseif(Parameters.methodFlag == 2)

    
    %Initialize P
    P = DirichletSample(ones(Parameters.N, Parameters.M));
    

    %Evaluate Samples
    Term1 = (-1/2)*(E - P*M').^2;
    Term2 = (-1/2)*(S - P*V').^2;
    LnLikelihoodNew = sum(Term1 + Term2,2);
    
    pTrack = zeros(Parameters.NumIterations, Parameters.N, Parameters.M);
    pTrack(1,:,:) = P;
    lTrack = zeros(Parameters.N, Parameters.NumIterations);
    lTrack(:,1) = LnLikelihoodNew;
    
    %Iterate and Sample
    for iter = 2:Parameters.NumIterations
         
        %Sample P
        [psamples] = DirichletSample(ones(Parameters.N,Parameters.M));
        Term1 = (-1/(2*Parameters.sigM))*(E - psamples*M').^2;
        Term2 = (-1/(2*Parameters.sigV))*(S - psamples*V').^2;
        LnLikelihoodNew = sum(Term1 + Term2,2);
        %LnLikelihoodNew = sum(Term1,2);
        
        %Evaluate Sample;
        acceptRatio = exp(LnLikelihoodNew - lTrack(:, iter-1));
        r = rand(Parameters.N, 1);
        test = repmat(acceptRatio > r, [1, Parameters.M]);
        pTrack(iter,:,:) = test.*psamples + (1-test).*squeeze(pTrack(iter-1,:,:));
        lTrack(:,iter) = test(:,1).*LnLikelihoodNew + (1-test(:,1)).*lTrack(:, iter-1);
        
    end
    
    [~, loc] = max(lTrack,[],2);
    P = zeros(Parameters.N, Parameters.M);
    for n = 1:Parameters.N
        P(n,:) = squeeze(pTrack(loc(n),n,:));
    end
    
else
    error('not yet implemented');
    P = [];
end
end

function [psamples] = DirichletSample(A)

Y        = randg(A) ; %Sample proportions under consideration
v        = sum(Y,2);
psamples = Y./repmat(v, [1, size(A,2)]);

end
