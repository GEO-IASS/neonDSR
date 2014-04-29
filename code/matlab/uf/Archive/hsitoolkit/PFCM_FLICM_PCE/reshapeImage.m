function [X] = reshapeImage(img)

[n_row,n_col,n_band] = size(img);
X = reshape(img,n_row*n_col,n_band)';
