function [kbc_out,kbc_cluster,alpha,beta] = kbc_anomaly(hsi_img,mask,k)
%
%[kbc_out,kbc_cluster,alpha,beta] = kbc_anomaly(hsi_img,mask,k)
%
% K-Betas Clustering Based Anomaly Detector
%  clusters data using K-Beta distributions (a-la K-means)
%  computes negative log likelihood of test point to closest Beta distribution
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%  k - number of beta components to use
%
% outputs:
%   kbc_out - detector output image
%   kbc_cluster - cluster assignment image
%   alpha - cluster alpha parameters
%   beta - cluster beta parameters
%
% 8/24/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

if ~exist('k','var'); k = []; end
if ~exist('mask','var'); mask = []; end

[kbc_out,kbc_cluster,alpha,beta] = img_det(@kbc_det,hsi_img,[],mask,k);

function [kbc_data,part,alpha,beta] = kbc_det(hsi_data,~,k)

[part,ll,alpha,beta] = kbetas_cluster(hsi_data,k);

kbc_data = ll;

