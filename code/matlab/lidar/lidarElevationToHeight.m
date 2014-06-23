function height_map = lidarElevationToHeight( Zmap, radius)
% This method converts elevation data to height via a subtracting a minimum sliding window
%Zmap is a 2D matrix of land and their elevations.
% the algorithms is to create a minimum matrix by replacing each element
% with the minimum of its neighbors at radius.. its like moving a
% minimizing sliding window

%ordfilt2 does the minimization of neighbors for a window
% http://dsp.stackexchange.com/questions/12582/what-exactly-does-ordfilt2-do
% http://medim.sth.kth.se/6l2872/F/F7-1.pdf

window = ones(radius) ; 

%nth_element = numel(window); % gives the maximum of neighbors.

% matrix of minimums in window neighborhood of pixel
min_matrix = ordfilt2(Zmap, 1, window); 
height_map = Zmap - min_matrix;

end

