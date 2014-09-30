function init()
% inits params

format long g; % avoid scientific notation
global setting
setting = struct('RED_INDEX', 34, 'NIR_INDEX', 41, 'GREEN_INDEX', 20, ...
    'BLUE_INDEX', 10, 'NDVI_THRESHOLD', 0.4, 'NIR_THRESHOLD', 0.33, ...
    'FIELD_PATH', '/cise/homes/msnia/zproject/neonDSR/docs/field_trips.csv', ...
    'SPECTRAL_LIBRARY', '/cise/homes/msnia/zproject/neonDSR/docs/spectral_library.csv');

end