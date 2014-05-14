function smoothedVector = gaussian_smoothing( vector, windowWidth)
  % Construct blurring window.

  if nargin < 2
    windowWidth = 4;
  end
  
  halfWidth = windowWidth / 2;

  gaussFilter = gausswin(windowWidth);
  gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
  smoothedVector = conv(vector, gaussFilter);   % Do the blur.
  smoothedVector = smoothedVector(halfWidth:end-halfWidth);
end

