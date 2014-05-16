function pixel = gaussianSmoothing( pixel, windowWidth)
% Construct blurring window.

if nargin < 2
    windowWidth = 4;
end

if ndims(pixel) == 2 && size(pixel,1) == 1 % single pixel
    halfWidth = windowWidth / 2;
    
    gaussFilter = gausswin(windowWidth);
    gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
    smoothedVector = conv(pixel, gaussFilter);   % Do the blur.
    smoothedVector = smoothedVector(halfWidth:end-halfWidth);
elseif ndims(pixel) == 2 % list of pixels
    for i=1:size(pixel, 1)
        halfWidth = windowWidth / 2;
        
        gaussFilter = gausswin(windowWidth);
        gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
        smoothedVector = conv(pixel(i,:), gaussFilter);   % Do the blur.
        smoothedVector = smoothedVector(halfWidth:end-halfWidth);
        pixel(i,:) = smoothedVector;
    end
elseif ndims(pixel) == 3 % 2D map of pixels
    for i=1:size(pixel, 1)
        for j=1:size(pixel, 2)
            
            halfWidth = windowWidth / 2;
            
            gaussFilter = gausswin(windowWidth);
            gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
            smoothedVector = conv(pixel(i,j,:), gaussFilter);   % Do the blur.
            smoothedVector = smoothedVector(halfWidth:end-halfWidth);
            pixel(i,j,:) = smoothedVector;
        end
    end
end

end

