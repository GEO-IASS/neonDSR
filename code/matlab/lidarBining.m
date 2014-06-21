function lidarBining(s)
% lidar bining and averaging

yy = s.Y;
xx = s.X;
zz = s.Z;
dx = 1;
dy = 1;
zmean= mean(zz);
zstd = std(zz);
zz = zz(zz <zmean + 3 * zstd );
xx = xx(zz <zmean + 3 * zstd );;
yy = yy(zz <zmean + 3 * zstd );;


yidx=[min(yy):dy:max(yy)];
xidx=[min(xx):dx:max(xx)];
ZmapSum=zeros(length(yidx),length(xidx));
ZmapIdx=zeros(size(ZmapSum));

[nx,binx] = histc(xx,xidx);
[ny,biny] = histc(yy,yidx);
%bin==0 means the value is out of range
binx=binx+1; biny=biny+1;
%binzero=( (binx==0) | (biny==0) );
%binx(binzero) = [];
%biny(binzero) = [];
%xx(binzero) = [];
%yy(binzero) = [];
%zz(binzero) = [];

%binx and biny give their respective bin locations
for i=1:1:length(xx)
    ZmapSum(biny(i),binx(i))=ZmapSum(biny(i),binx(i))+zz(i);
    ZmapIdx(biny(i),binx(i))=ZmapIdx(biny(i),binx(i))+1; % keep track of how many points it is
end

Zmap=ZmapSum./ZmapIdx;

imagesc(Zmap');

end