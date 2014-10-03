function height = getHeight( heightMap, baseEasting, baseNorthing, binResolution, targetEasting, targetNorthing )
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

targetIndexEasting = (targetEasting - baseEasting) / binResolution;
targetIndexNorthing = (targetNorthing - baseNorthing) / binResolution;


height = heightMap(round(targetIndexNorthing), round(targetIndexEasting));


end

