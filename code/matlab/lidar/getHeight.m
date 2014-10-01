function height = getHeight( heightMap, baseEasting, baseNorthing, binResolution, targetEasting, targetNorthing )
%GETHEIGHT Summary of this function goes here
%   Detailed explanation goes here

if targetEasting < baseEasting || targetEasting > baseEasting + size(heightMap, 2) * binResolution
    height = NaN;
    return;
end
if targetNorthing < baseNorthing || targetNorthing > baseNorthing + size(heightMap, 1) * binResolution
    height = NaN;
    return;
end

targetIndexEasting = (targetEasting - baseEasting) / binResolution;
targetIndexNorthing = (targetNorthing - baseNorthing) / binResolution;


height = heightMap(round(targetIndexNorthing), round(targetIndexEasting));


end

