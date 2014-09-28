function [baseX, baseY, Zmap] = lidarBining(s, bin_resolution)
% lidar bining, taking maximum in pixel, the 0th pixel is located at (baseX
% + 0 * bin_resolution, baseY + 0 * bin_resolution)

baseX=min(s.X);
baseY=min(s.Y);

yidx=min(s.Y):bin_resolution:max(s.Y);
xidx=min(s.X):bin_resolution:max(s.X);

Zmap=NaN(length(yidx),length(xidx));

[bincountx,binx] = histc(s.X,xidx);
[bincounty,biny] = histc(s.Y,yidx);

% observe distribution of points per bin in each dimension
figure, plot(1:size(bincountx), bincountx);
figure, plot(1:size(bincounty), bincounty);

%bin==0 means the value is out of range
binx=binx+1; biny=biny+1;

%comments by original author
%binzero=( (binx==0) | (biny==0) ); %binx(binzero) = []; %biny(binzero) = [];%xx(binzero) = [];%yy(binzero) = [];%zz(binzero) = [];

%binx and biny give their respective bin locations
for i=1:1:length(s.X)
    %ZmapSum(biny(i),binx(i))=ZmapSum(biny(i),binx(i))+zz(i);
    %ZmapIdx(biny(i),binx(i))=ZmapIdx(biny(i),binx(i))+1; % keep track of how many points it is

    %disp([biny(i),binx(i)])
    if (isnan(Zmap(biny(i),binx(i))) || s.Z(i) > Zmap(biny(i),binx(i)))
        Zmap(biny(i),binx(i)) = s.Z(i); % take maximum
    else
        ;
        %disp([ZmapSum(biny(i),binx(i)) zz(i)]);
    end
        
end

end