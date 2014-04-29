function [parameters]=BISPICE_Parameters()

%Alternating Optimization Params
parameters.iter = 5000;
parameters.e_max_iter = 1;
parameters.e_iter_cutoff = 1e-9;
parameters.cutoff = 1e-7;

%Sparsity and Regularization parameters (Change These)
parameters.bgamma = 0.1;	%Bilinear Gamma or Gamma_B
parameters.gamma = 0.5;		%Linear Gamma or Gamma_L
parameters.u = 0.01;		%mu as in SPICE
parameters.M = 8;		%Initial # of Linear Endmembers

%Pruning Parameters
parameters.endmemberPruneThreshold = 1e-7;
parameters.resetBilinearOnPrune = true;

%Testing purposes only
parameters.initial_endmembers = [];
parameters.unmix_only = false;


