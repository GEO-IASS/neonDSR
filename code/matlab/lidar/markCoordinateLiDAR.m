function [ imageindex ] = markCoordinateLiDAR( lidar_figure, heightMap, baseX, baseY,  bin_resolution, x, y )

    x_index = -1;
    y_index = -1;
    
x_index = floor((x - baseX)/bin_resolution + 1);
y_index = floor((y - baseY)/bin_resolution + 1);
%disp([x , y , x_index, y_index]);
if x_index <= size(heightMap, 2) && y_index <= size(heightMap, 1)
        figure(lidar_figure);
        hold on
        plot(  x_index,  y_index, '.', 'Color', [1 0.78 0.80],  'MarkerSize', 15)
        hold off
        imageindex = [x_index y_index];
else
    disp('Err in dimension finding');
end

   % for i=1:size(heightMap, 1)
   %     if baseX + i * bin_resolution <= x &&  baseX + (i+1) * bin_resolution >= x
   %         x_index = i;
   %     end
   % end
   % for i=1:size(heightMap, 2)
   %     if baseY + i * bin_resolution <= y && baseY + (i+1) * bin_resolution >= y
   %         y_index = i;
   %     end
   % end

   % if x_index == -1 || y_index == -1
   %     disp('Coordinates are out of bound');
   % else
   %     figure(1);
   %     hold on
   %     plot(x_index, y_index, 'r.', 'MarkerSize', 15)
   %     hold off
   %     imageindex = [x_index y_index];
   % end
end

