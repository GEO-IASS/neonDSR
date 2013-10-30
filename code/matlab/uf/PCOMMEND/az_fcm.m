function [Membership, Centers] = az_fcm(X, NumClusters)

mFuzzifier = 2;

%Initialization
stopThresh = 1e-5;
[NumPoints, NumDims] = size(X);
ImageList = X';
Membership = rand(NumPoints, NumClusters);
Membership = Membership./repmat(sum(Membership')', [1, NumClusters]);
Centers = ones(NumClusters, NumDims);
continueFlag = 1;

while(continueFlag)
    prevMembership = Membership; 
    
    %Update Cluster Centers
    Centers = ((Membership.^mFuzzifier)'*ImageList')./repmat(sum((Membership.^mFuzzifier))', [1, NumDims]);
    
    %Update Membership
    D = (1./(pdist2(ImageList', Centers)).^2).^(1/(mFuzzifier-1));
    S = sum((D)')';
    Membership = D./repmat(S, [1, NumClusters]);
    
    %Check Convergence
    n = max(max(abs(Membership - prevMembership)));
    if(n < stopThresh)
        continueFlag =0;
    end
    
end

Membership = Membership';