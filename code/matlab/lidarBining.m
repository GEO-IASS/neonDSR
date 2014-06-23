function Zmap = lidarBining(s, bin_size)
% lidar bining, averaging, and removing outliers in elevation (clouds)

yy = s.Y;
xx = s.X;
zz = s.Z;
dx = bin_size; % meters
dy = bin_size;


yidx=[min(yy):dy:max(yy)];
xidx=[min(xx):dx:max(xx)];
%ZmapSum=zeros(length(yidx),length(xidx));
ZmapSum=NaN(length(yidx),length(xidx));
ZmapIdx=zeros(size(ZmapSum));

[nx,binx] = histc(xx,xidx);
[ny,biny] = histc(yy,yidx);
%bin==0 means the value is out of range
binx=binx+1; biny=biny+1;

%comments by original author
%binzero=( (binx==0) | (biny==0) ); %binx(binzero) = []; %biny(binzero) = [];%xx(binzero) = [];%yy(binzero) = [];%zz(binzero) = [];

%binx and biny give their respective bin locations
for i=1:1:length(xx)
    %ZmapSum(biny(i),binx(i))=ZmapSum(biny(i),binx(i))+zz(i);
    %ZmapIdx(biny(i),binx(i))=ZmapIdx(biny(i),binx(i))+1; % keep track of how many points it is

    if (isnan(ZmapSum(biny(i),binx(i))) || zz(i) > ZmapSum(biny(i),binx(i)))
        ZmapSum(biny(i),binx(i)) = zz(i); % take maximum
    end
        
end

%Zmap=ZmapSum./ZmapIdx;
Zmap = ZmapSum;
%Zmap(isnan(Zmap)) = 0; 

end