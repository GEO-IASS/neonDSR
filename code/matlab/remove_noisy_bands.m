function output_img = remove_noisy_bands( hsi_img )

output_img = hsi_img;
output_img(:,:,105:120) = NaN;
output_img(:,:,151:171) = NaN;
output_img(:,:,215:224) = NaN;

end

