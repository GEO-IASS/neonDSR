function [endmembers, P] = FUMI(inputData, labels, parameters)

% inputs:
%  inputData (Ndimension x Nsamples) - input data as column vectors
%  labels (Ntargets x Nsamples) - column all 0 if sample is background, 1 at labels(i,j) if target i present in sample j
%  parameters - parameters structure as returned by FUMIParameters()

parameters.pruningIteration = 1;
M                           = parameters.M;
parameters.labels           = labels;
NumLabeled                  = sum(labels(:)) - length(find(sum(labels,1) > 1));
X                           = inputData;

if(isnan(parameters.initEM))
    %Find Random Initial Endmembers
    randIndices = randperm(size(inputData,2));
    randIndices = randIndices(1:parameters.M);
    parameters.initEM   = inputData(:,randIndices);
else
    parameters.M        = size(parameters.initEM, 2);    
end
endmembers = parameters.initEM;


%N is the number of pixels, d is the dimension size, RSSreg is the current
%objective function total.
N       = size(X,2);
d       = size(endmembers,1);
RSSreg  = inf;
change  = inf;
oTT     = zeros(4,1);

Mcounter        = [];
pruneCounter    = 0;
iteration       = 0;
P               = ones(N,M)*(1/M);

%Set W
Wt  = (parameters.tWeight*(size(labels,2) - NumLabeled)/NumLabeled);
W   = ones(N,1);
W(sum(labels,1) > 0) = Wt;

while( change > parameters.changeThresh && iteration < parameters.iterationCap)
    
    Mcounter        = horzcat(Mcounter, M);
    iteration       = iteration + 1;
    pruneCounter    = pruneCounter+1;

    %Given Endmembers, minimize P
    %Quadratic Programming Problem
    [P] = unmix3(X, endmembers, parameters.gamma, P, parameters);
      
    %Given P minimize Endmembers    
    endmembersPrev = endmembers;
    

    if parameters.physically_correct_endmembers
        
        endmembers = solve_endmembers(X,endmembers,P, parameters);
        
    else
        
        lambda = N*parameters.u/((M-1)*(1-parameters.u));
        Im = eye(M);
        ones_by_m = ones(M,M)/M;
                
        endmembers = zeros(d,M);
        Pt_dW = P'*diag(W);
        numer = Pt_dW*P + lambda*(Im - ones_by_m);
        
        for j = 1:d
            endmembers(j,:) = (numer\(Pt_dW*X(j,:)'))';
        end
    end
    
    pruneFlag = 0;
    if(pruneCounter == parameters.pruningIteration)
        pruneCounter = 0;
        %Prune Endmembers below pruning threshold
        pruneIndex = max(P)<parameters.endmemberPruneThreshold;
        minmaxP = min(max(P));
        if(sum(pruneIndex) > 0)
            pruneFlag = 1;
        end
        em = [];
        ptemp = [];
        for j = 1:M
            if(pruneIndex(j) == 0)
                em = horzcat(em, endmembers(:,j));
                ptemp = horzcat(ptemp, P(:,j));
            end
        end
        endmembers = em;
        P = ptemp;
        clear em ptemp;
        M = M - sum(pruneIndex);
    end
    
    %Calculate RSSreg (the current objective function value)
    sqerr = zeros(d,1);
    for j = 1:d
        err = (X(j,:)'-P*endmembers(j,:)');
        sqerr(j) = err'*err;
    end
    RSS = sum(sqerr);
    
    % calculate sum of SSD by sum of endmember variances
    em_var = sum(endmembers.*endmembers,2) - (1/M)*sum(endmembers,2).^2;   
    SSD = M*sum(em_var);

    V = SSD/((M-1)*M);
    RSSprev = RSSreg;
    gammaVecs = zeros(M,1);
    for k = 1:M
        gammaVecs(k) = parameters.gamma/sum(P(:,k));
    end
    
    % calculate sparsity promotion term SPT
    prop_wt = zeros(M,1);
    for k = 1:M
        prop_wt(k) = gammaVecs(k)*sum(P(:,k));
    end
    SPT = sum(prop_wt);
    RSSreg = (1-parameters.u)*(RSS/N) + parameters.u*V;

    oTT(1,iteration) = (1-parameters.u)*(RSS/N);
    oTT(2,iteration) = parameters.u*V;
    oTT(3,iteration) = SPT;
    oTT(4,iteration) = pruneFlag;
    oTT(5,iteration) = minmaxP;
    
    %Determine if Change Threshold has been reached
    if(pruneFlag)
        change = 1;
    else
        change = norm(endmembers - endmembersPrev);
    end
    if(change < parameters.changeThresh )
        disp('Stopping based on change threshold.');
    end

    if(parameters.produceDisplay)
        disp(' ');
        disp(strcat('Change in RSSreg: ', num2str(change)))
        disp(strcat('Minimum of Maximum Proportions: ', num2str(minmaxP)))
        disp(strcat('(1-parameters.u)*(RSS/N): ', num2str(oTT(1,iteration))))
        disp(strcat('parameters.u*V: ', num2str(oTT(2,iteration))))
        disp(strcat('SPT: ', num2str(oTT(3,iteration))))
        disp(strcat('pruneFlag: ', num2str(oTT(4,iteration))))
        disp(strcat('Number of Endmembers: ', num2str(M)))
        disp(strcat('Iteration: ', num2str(iteration)))
        disp(' ');
    end

    
end


