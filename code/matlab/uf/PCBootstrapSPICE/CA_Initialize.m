function [E,U] = CA_Initialize(X,C)

% This function initialize
%   - U: the fuzzy membership matrix (CXN), and
%   - X: Pixel points (NXd)
%   - C: Number of clusters
% output:
%   - P:  Cell of C abundance matrices. One (NXM) matrix per cluster,
%   - U1: the fuzzy membership matrix (CXN),

options = [2];
[U, E] = FCM(X, C, options);