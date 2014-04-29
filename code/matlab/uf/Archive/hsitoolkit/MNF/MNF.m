function [out_img,A,mu,eigvals] = MNF(in_img,params)

% get the noise covariance

% assumes neighbor pixels are essentially the same except for noise
%   use a simple mask of neighbor pixels to the right and below
[n_row,n_col,n_band] = size(in_img);
n_pix = n_row*n_col;

hsi_data = double(reshape(in_img,[n_pix,n_band])');

mu = mean(hsi_data,2);

running_cov = zeros(n_band,n_band);

for i=1:n_col - 1
    for j=1:n_row - 1
        
        diff1 = squeeze(in_img(j,i+1,:) - in_img(j,i,:));
        diff2 = squeeze(in_img(j+1,i,:) - in_img(j,i,:));
        
        running_cov = running_cov + diff1*diff1' + diff2*diff2';                
        
    end
end

noise_cov = 1/(2*(n_row-1)*(n_col-1) - 1) * running_cov;

[noiseU,noiseS,noiseV] = svd(noise_cov);

% align and whiten noise
hsi_prime = pinv(sqrt(noiseS)) * noiseU * (hsi_data - repmat(mu,1,n_pix));
%hsi_prime = pinv(sqrt(noiseS)) * noiseU * (hsi_data);

% PCA the noise whitened data
[U,S,V] = svd(cov(hsi_prime')); % svd returns eigs in decreasing order

hsi_mnf = U*hsi_prime;

out_img = reshape(hsi_mnf',[n_row,n_col,n_band]);

A = U * pinv(sqrt(noiseS)) * noiseU;
eigvals = diag(S);

if params.dim_reduce
   
   pcts = cumsum(eigvals)/sum(eigvals);
   
   cut_ind = find(pcts >= params.en_pct,1,'first');
   
   out_img = out_img(:,:,1:cut_ind);
end


