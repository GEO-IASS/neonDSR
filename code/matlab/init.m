function envi = init()
% inits params and just scales envi.

format long g; % avoid scientific notation
global setting
setting = struct('RED_INDEX', 34, 'NIR_INDEX', 41, 'GREEN_INDEX', 20, ...
    'BLUE_INDEX', 10, 'NDVI_THRESHOLD', 0.4, 'NIR_THRESHOLD', 0.33, ...
    'FIELD_PATH', '/cise/homes/msnia/zproject/neonDSR/docs/field_trip_28022014/crowns_osbs_atcor_flight4_morning.csv');

%envi.info.wavelength(setting.NIR_INDEX)

%% Read ENVI file and Normalize ata reflectance range = [-32724, +32762]

if exist('/cise/', 'file')
    cd('/cise/homes/msnia/zproject/neonDSR/code/matlab');
    addpath(genpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/'));
    %envi = enviread('/cise/homes/msnia/neon/morning/f100904t01p00r04rdn_b/f100904t01p00r04rdn_b_sc01_ort_img_atm.bsq');
    
    envi = enviread('/cise/homes/msnia/neon/midday/f100910t01p00r04rdn_b/f100910t01p00r04rdn_b_sc01_ort_img_atm.bsq');
    %envi = enviread('/cise/homes/msnia/neon/morning/f100910t01p00r04rdn_b_NEON-L1G/f100910t01p00r04rdn_b_sc01_ort_flaashreflectance_img');
else
    cd('/home/scidb/zproject/neonDSR/code/matlab/');
    envi = enviread('/home/users-share/allFlights/f100910t01p00r03rdn_b_NEON-L1G/f100910t01p00r03rdn_b_sc01_ort_flaashreflectance_img');
end

checkXYsHaveUniformStepSizes(envi);

envi.z = double(envi.z);

for j = 1: size(envi.z, 2)
    for i = 1: size(envi.z, 1)
        
        envi.z(i, j, :) = scalePixel(envi.z(i,j,:));
    end
end

end