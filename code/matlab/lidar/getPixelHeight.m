function height = getHeight( heightMap, baseEasting, baseNorthing, binResolution, targetEasting, targetNorthing, DEBUG )
% You might want to add more flight lines to the aggregate lidar file to
% make sure you get abundance of point clouds just in case there might be
% more points fro there. But for now this is good enough with current
% computation power.

% Assuming that a pixel might be captured in its actual flight and/or
% two adjacent flights, make sure the coordinates are in flight
% boundary

if targetEasting < baseEasting || targetEasting > baseEasting + size(heightMap, 2) * binResolution
    height = NaN;
    disp('out of bound');
    return;
end
if targetNorthing < baseNorthing || targetNorthing > baseNorthing + size(heightMap, 1) * binResolution
    height = NaN;
    disp('out of bound');
    return;
end

targetIndexEasting = round((targetEasting - baseEasting) / binResolution);
targetIndexNorthing = round((targetNorthing - baseNorthing) / binResolution);

height = heightMap(targetIndexNorthing, targetIndexEasting);


if DEBUG
    disp([targetIndexEasting, targetIndexNorthing height]);
end

end

