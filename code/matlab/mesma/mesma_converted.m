resids = function viper_mesma_fraccalc(em_array, image_line) % function viper_mesma_fraccalc, em_array, image_line, resids=resids
% compile_opt idl2
% on_error, 2

% ; get the data type of the input endmember array
% data_type = size(em_array, /type)

% ; get the number of endmembers and number of bands
dims = size(em_array) % dims = size(em_array, /dimensions)
n_ems = dims[0];
nb = dims[1];

%; run a singular value decomposition on the endmember array where:
%; w = n element vector containing the eigenvalues
%; u = n column by m row orthogonal array used in decomposition
%; v = n column by n row orthogonal array used in decomposition
[w,u,v] = svd(em_array); % svdc,em_array,w,u,v

% ; fill w_inv as diagonal matrix where values are 1 over the eigenvalues
% w_inv=(1/w)##(bytarr(n_ems)+1)*identity(n_ems)

% if according to svd M=U*S*V then the M_inverse=V*S_inverse*U' 
% http://adrianboeing.blogspot.com/2010/05/inverting-matrix-svd-singular-value.html

% ; calculate inverse matrix
em_inv = v * inv(w) * u';% em_inv = v##w_inv##transpose(u)



; do matrix multiplication of em_mat_inv matrix by the image spectra
frac = em_inv##image_line

; calculate the shade fraction, while constraining the fractions to sum to one
; by subtracting the sum of the fractional abundances of all other EMs from one.
if n_ems eq 1 then shade=1-frac else shade=1-total(frac,2)
model = em_array##frac ; calculate the modeled spectra
resids = image_line - model

; calculate root mean square error from residuals
rmse = sqrt(total(resids^2,2)/nb)

; place fractions (ems and shade) and rmse in output structure
sma={frac:frac, $
    shade:shade, $
    rmse:rmse}

return, sma
end
