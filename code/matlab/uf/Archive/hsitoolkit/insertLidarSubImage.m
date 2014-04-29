function HSIStruct = insertLidarSubImage(HSIStruct, LidarFilenames);

% HSIStruct = insertLidarSubImage(HSIStruct, LidarFilenames);
%LidarFilenames is a cell array containing all Lidar images to intersect
%with the given HSI Structu

numLidarImages = length(LidarFilenames);

%Load LIDAR Imagery
for i = 1:numLidarImages
    LidarIms{i} = enviread(LidarFilenames{i});
end

%Intersect with HSI Imagery
for i = 1:numLidarImages
    diffE = dist(LidarIms{i}.x', HSIStruct.Easting);
    [~, locE] = min(diffE,[],1);
    
    
    diffN = dist(LidarIms{i}.y', HSIStruct.Northing);
    [~, locN] = min(diffN,[],1);
    
    LidarIms{i}.z = LidarIms{i}.z(locN, locE,:);
    LidarIms{i}.x = LidarIms{i}.x(locE);
    LidarIms{i}.y = LidarIms{i}.y(locN);
end

HSIStruct.Lidar = LidarIms;
