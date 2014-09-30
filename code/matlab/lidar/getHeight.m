function height = getHeight( heightMap, baseX, baseY, binResolution, targetX, targetY )
%GETHEIGHT Summary of this function goes here
%   Detailed explanation goes here

if targetX < baseX || targetX > baseX + size(heightMap, 2) * binResolution
    height = NaN;
    return;
end
if targetY < baseY || targetY > baseY + size(heightMap, 1) * binResolution
    height = NaN;
    return;
end

targetIndexX = (targetX - baseX) / binResolution;
targetIndexY = (targetY - baseY) / binResolution;


height = heightMap(round(targetIndexY), round(targetIndexX));


end

