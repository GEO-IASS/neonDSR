function height = getHeight( heightMap, baseEasting, baseNorthing, binResolution, targetEasting, targetNorthing, DEBUG )
% TODO Looks like the neon website is down and nothin is ready to download
% for other lidar flights. as we get no signals for certain field sampels
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

