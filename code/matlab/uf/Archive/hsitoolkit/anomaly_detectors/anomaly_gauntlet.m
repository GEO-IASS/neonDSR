function [scores,det_out,names] = anomaly_gauntlet(hsi,img,filt,title_str,roc_figh)
%
%function [scores,det_out,names] = anomaly_gauntlet(hsi,img,filt,title_str,roc_figh)
%
% run the gauntlet of anomaly detector tests for
% the given image
%
% 10/1/2012 - Taylor C. Glenn - tcg@cise.ufl.edu

if ~exist('roc_figh','var'); roc_figh = []; end

%-------------------------------------------------------------------------------
i = 1;
det_out{i} = md_anomaly(img);
names{i} = 'Mahalanobis Distance';

i = i+1;
det_out{i} = rx_anomaly(img,2,3);
names{i} = 'RX';

i = i+1;
det_out{i} = ssrx_anomaly(img,round(size(img,3)*2/3),2,3);
names{i} = 'Subspace RX';

i = i+1;
det_out{i} = csd_anomaly(img,2,[],true);
names{i} = 'Complementary Subspace Detector';

i = i+1;
det_out{i} = gmm_anomaly(img,[],8);
names{i} = 'Gaussian Mixture Model';

i = i+1;
det_out{i} = gmrx_anomaly(img,[],8);
names{i} = 'Gaussian Mixture RX';

i = i+1;
det_out{i} = cbad_anomaly(img,[],8);
names{i} = 'CBAD';

i = i+1;
det_out{i} = fcbad_anomaly(img,[],8);
names{i} = 'FCBAD';
%-------------------------------------------------------------------------------


n_det = i;

scores = cell(1,n_det);
for i=1:n_det
    scores{i} = score_hylid_perpixel(hsi,det_out{i},filt,names{i});
end

if ~isempty(roc_figh)
        
    figure(roc_figh);    
    PlotBullwinkleRoc(scores,title_str,names);
        
end



end