function params = MNFParameters()

params = struct();

params.dim_reduce = false;  %do a dimensionality reduction on final PCA step
params.en_pct = 0.99;       % if dim_reduce, percentage of eigenvalues to retain