function PlotBlobber(blobber_out,filter)

if ~exist('filter','var'); filter = []; end

image(sqrt(blobber_out.RGB));
hold on;

bin_img = blobber_out.Data > 0;

bh = imagesc(bin_img);
set(bh,'AlphaData',bin_img);

plot_hylid_gt(blobber_out.groundTruth,filter);

end