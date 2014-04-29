
% test out anomaly detection algorithms

%load ../../hylid_small/HylidImage.mat;
load ../../hylid_small/frontPark_subImage;
hsi = frontHylidImage;

%load ../../hylid_campus_images/campus_1127_with_1135_lidar.mat;
%hsi = campus_1127_with_1135_lidar;

hsi_img = hsi.Data;

[n_row,n_col,n_band] = size(hsi_img);
n_pix = n_row*n_col;

% set up scoring filter
filt = []; %{ {[],[3 6],[1],[]} };

% preprocess the data
hsi_data = double(reshape(hsi_img,[n_pix,n_band])');
%[pca_data,n_dim_pca] = pca(hsi_data,0.999);
[pca_data,n_dim_pca,pca_vecs,pca_vals,pca_mu,dr_hsi] = hdr_like_pca(hsi,20);
pca_img = reshape(pca_data',[n_row,n_col,n_dim_pca]);

% Mahalanobis distance
md_out = md_anomaly(pca_img);
md_scale = log10(md_out+1);

score_hylid_perpixel(hsi,md_scale,filt,'Mahalanobis Distance',figure(10),figure(11));

% Reed-Xiaoli
rx_out = rx_anomaly(pca_img,2,3);
rx_scale = log10(rx_out+1);

score_hylid_perpixel(hsi,rx_scale,filt,'RX',figure(12),figure(13));

% Subspace RX
ssrx_out = ssrx_anomaly(pca_img,2,2,3);
ssrx_scale = log10(ssrx_out+1);

score_hylid_perpixel(hsi,ssrx_scale,filt,'Subspace RX',figure(14),figure(15));

% complementary subspace detector
csd_out = csd_anomaly(pca_img,2,[],true);
csd_scale = log10(csd_out-min(csd_out(:))+1);

score_hylid_perpixel(hsi,csd_scale,filt,'Complementary Subspace Detector',figure(16),figure(17));

% Gaussian mixture model
gmm_out = gmm_anomaly(pca_img,[],4);
gmm_scale = gmm_out - min(gmm_out(:));

score_hylid_perpixel(hsi,gmm_scale,filt,'Gaussian Mixture Model Anomaly',figure(18),figure(19));

% Gaussian mixture based RX
gmrx_out = gmrx_anomaly(pca_img,[],4);
gmrx_scale = log10(gmrx_out+1);

score_hylid_perpixel(hsi,gmrx_scale,filt,'Gaussian Mixture RX Anomaly',figure(20),figure(21));

% CBAD k-means+MD anomaly
[cbad_out,cbad_cluster] = cbad_anomaly(pca_img,[],8);
cbad_scale = log10(cbad_out+1);

score_hylid_perpixel(hsi,cbad_scale,filt,'CBAD',figure(22),figure(23));

% FCBAD FCM+MD anomaly
[fcbad_out,fcbad_cluster] = fcbad_anomaly(pca_img,[],8);
fcbad_scale = log10(fcbad_out+1);

score_hylid_perpixel(hsi,fcbad_scale,filt,'FCBAD',figure(24),figure(25));


% experimental/research anomaly detectors
% note: beta related detectors require data in range [0-1]
%  use with full-band reflectance or hierarchical dim reduced data

beta_out = beta_anomaly(pca_img);
score_hylid_perpixel(hsi,beta_out,filt,'Beta Anomaly',figure(120),figure(121));

[kbc_out,kbc_cluster] = kbc_anomaly(pca_img,[],8);
score_hylid_perpixel(hsi,kbc_out,filt,'K-Betas Clustering Anomaly',figure(122),figure(123));


