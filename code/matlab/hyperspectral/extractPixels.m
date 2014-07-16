function [specie_titles, reflectances] = extractPixels( envi, fieldPath )
%% gets coordinates of pixels from text file and just returns their reflectance value

[ specie_titles, ~, info ] = loadGroundCSVFile( fieldPath);

x_list=info(:,6); y_list =info(:, 7);

x_step_size = abs(envi.x(2) - envi.x(1));
y_step_size = abs(envi.y(2) - envi.y(1));

reflectances = zeros(numel(x_list), size(envi.z, 3));
for i = 1: numel(x_list)
    XCoord = x_list(i);
    YCoord = y_list(i);
    
    if (x_list(i) < envi.x(1)) || (x_list(i) > envi.x(numel(envi.x))) || (y_list(i) < envi.y(numel(envi.y))) || (y_list(i) > envi.y(1))
        error('Coordinates not in image bounds');
    end
    x = -1;
    y = -1;
    % find index of the X coordinate
    for i0=1:size(envi.x')
        if abs(envi.x(i0) - XCoord) < x_step_size
            x = i0;
        end
    end
    
    for i0=1:size(envi.y')
        if abs(envi.y(i0) - YCoord) < y_step_size
            y = i0;
        end
    end
    
    reflectances(i, :) = reshape(envi.z(y,x,:), 1, size(envi.z, 3));
end


% these cleanings are already done in envi itself!!!
%reflectances = removeWaterAbsorbtionBands( reflectances, 0);
% x = 1:size(reflectances,2); figure; plot(x,reflectances);
%reflectances = gaussianSmoothing(reflectances, 4);
% x = 1:size(reflectances,2); figure; plot(x,reflectances);


%for i = 1:size(reflectances, 1)
%    reflectances(i,:) = scalePixel(reflectances(i,:));
%end
x = 1:size(reflectances,2); figure; plot(x,reflectances);


end

