function [psamples] = DirichletSample(NPts, AlphaVector)        


A        = repmat(AlphaVector, [NPts, 1]);
Y        = randg(A) ; %Sample proportions under consideration
v        = sum(Y,2);
psamples = Y./repmat(v, [1, size(A,2)]);