function height_map = lidarElevationToHeight( Zmap, radius)
% This method converts elevation data to height via a subtract ing a minimum sliding window
%Zmap is a 2D matrix of land and their elevations.
% the algorithms is to move a sliding window of size e.g. 3 and take the
% minimum there and subtract the middle point from the min.

%ordfilt2 does the minimization of neighbors for a window
% http://dsp.stackexchange.com/questions/12582/what-exactly-does-ordfilt2-do


window = ones(radius) ; % make sure the actual pixel is in the middle
nth_element = numel(window);
% matrix of minimums in window neighborhood of pixel
min_matrix = ordfilt2(Zmap, 1, window); 
height_map = Zmap - min_matrix;

end

