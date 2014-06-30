function resampled_values = resample( wavelengths, values, base_wavelengths )
% Thsi function takes as input a set of reading s and outputs the
% equivalent values in NEON wavelengths set.

resampled_values = zeros(1,numel(base_wavelengths));

for i=1:numel(base_wavelengths)
    w_gt = wavelengths > base_wavelengths(i);
    if i ~= numel(base_wavelengths)
        w_lt = wavelengths < base_wavelengths(i+1);
        w_index_range = and(w_gt, w_lt);
    else
        w_index_range = w_gt;
    end
    inrange_values = values(w_index_range);
    resampled_values(i) = mean(inrange_values);
end

end

