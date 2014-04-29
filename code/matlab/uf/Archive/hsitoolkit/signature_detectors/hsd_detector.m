function [hsd_out,tgt_p] = hsd_detector(hsi_img,tgt_sig,mask,ems)
%
%function [hsd_out,tgt_p] = hsd_detector(hsi_img,tgt_sig,mask,ems)
%
% Hybrid Structured Detector Detector
%  (from the department of redundancy department,
%   please enter your PIN number at the ATM machine)
%
%  ref:
%  Hybrid Detectors for Subpixel Targets
%  Broadwater, J. and Chellappa, R.
%  Pattern Analysis and Machine Intelligence, IEEE Transactions on
%  2007 Volume 29 Number 11 Pages 1891 -1903 Month nov.
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%  ems - background endmembers
%
% outputs:
%  hsd_out - detector image
%  tgt_p - target proportion in unmixing
%
% 8/19/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

[hsd_out,tgt_p] = img_det(@hsd_det,hsi_img,tgt_sig,mask,ems);

end

function [hsd_data,tgt_p] = hsd_det(hsi_data,tgt_sig,ems)

[n_band,n_pix] = size(hsi_data);

params = struct();
params.sum_to_one = true;

% unmix data with only background endmembers

P = unmix2(hsi_data,ems,params); %unmix2 from FUMI directory currently
% unmix data with target signature as well

targ_P = unmix2(hsi_data,[tgt_sig ems],params); 

siginv = pinv(cov(hsi_data'));
%siginv = eye(n_band);
% fixme: the HSD wants scaled noise covariance for sigma
%   assume that noise cov is equal to residual cov

%residual = hsi_data - ems*P';
%siginv = pinv(cov(residual'));

hsd_data = zeros(1,n_pix);

for i=1:n_pix
    z = hsi_data(:,i) - ems*P(i,:)';
    w = hsi_data(:,i) - [tgt_sig ems]*targ_P(i,:)';
    hsd_data(i) = (z'*siginv*z) / (w'*siginv*w);
end

tgt_p = targ_P(:,1:size(tgt_sig,2))';

end
