function maxPixelHeight = getPixelHeightInNeighborhood(heightMap, baseEasting, baseNorthing, binResolution, roiEasting, roiNorthing, DEBUG )
% looks into a neighborhood of the pixel and takes the max as its height,
% due to the fact that our coordinates might be a few meters off

pixelHeight = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting, roiNorthing, DEBUG );
if DEBUG
    disp([ roiEasting, roiNorthing, pixelHeight]);
end
p0   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting - binResolution, roiNorthing - binResolution, DEBUG);
p1   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting - binResolution, roiNorthing, DEBUG);
p2   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting, roiNorthing - binResolution, DEBUG);
p3   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting + binResolution, roiNorthing + binResolution, DEBUG);
p4   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting + binResolution, roiNorthing , DEBUG);
p5   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting, roiNorthing + binResolution, DEBUG);
p6   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting - binResolution, roiNorthing + binResolution, DEBUG);
p7   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting + binResolution, roiNorthing - binResolution, DEBUG);

p20   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting - 2 * binResolution, roiNorthing - 2 * binResolution, DEBUG);
p21   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting - 2 * binResolution, roiNorthing, DEBUG);
p22   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting, roiNorthing - 2 * binResolution, DEBUG);
p23   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting + 2 * binResolution, roiNorthing + 2 * binResolution, DEBUG);
p24   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting + 2 * binResolution, roiNorthing , DEBUG);
p25   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting, roiNorthing + 2 * binResolution, DEBUG);
p26   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting - 2 * binResolution, roiNorthing + 2 *  binResolution, DEBUG);
p27   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting + 2 * binResolution, roiNorthing - 2 * binResolution, DEBUG);

p28   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting + binResolution, roiNorthing + 2 * binResolution, DEBUG);
p29   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting - binResolution, roiNorthing + 2 *  binResolution, DEBUG);
p30   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting + 2 * binResolution, roiNorthing - binResolution, DEBUG);
p31   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting + 2 * binResolution, roiNorthing + binResolution, DEBUG);

p32   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting + binResolution, roiNorthing - 2 * binResolution, DEBUG);
p33   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting - binResolution, roiNorthing - 2 *  binResolution, DEBUG);
p34   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting - 2 * binResolution, roiNorthing - binResolution, DEBUG);
p35   = getPixelHeight( heightMap, baseEasting, baseNorthing, binResolution, roiEasting - 2 * binResolution, roiNorthing + binResolution, DEBUG);

max_neighbor_height = max([p0, p1, p2, p3, p4, p5, p6, p7, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35]);

maxPixelHeight = max([pixelHeight, max_neighbor_height]);

end

