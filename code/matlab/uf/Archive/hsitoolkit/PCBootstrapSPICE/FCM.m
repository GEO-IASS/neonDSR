function [Membership, Centers] = FCM(InputImage, NumClusters, mFuzzifier)

%Initialization
stopThresh = 1e-5;
NumDims = size(InputImage,2);
NumPoints = size(InputImage,1);
%ImageList = reshapeImage(InputImage);
ImageList = InputImage';
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

%for i = 1:NumClusters
%    M(:,:,i) = reshape(Membership(:,i), size(InputImage,1), size(InputImage,2));
%end

%Membership = M;