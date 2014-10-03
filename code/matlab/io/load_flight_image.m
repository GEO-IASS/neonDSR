function envi = load_flight_image( envi_file_path )
% Read ENVI file and Normalize ata reflectance range = [-32724, +32762]

%if exist('/cise/', 'file')
%    cd('/cise/homes/msnia/zproject/neonDSR/code/matlab');
%    addpath(genpath('/cise/homes/msnia/zproject/neonDSR/code/matlab/'));
    %envi = enviread('/cise/homes/msnia/neon/morning/f100904t01p00r04rdn_b/f100904t01p00r04rdn_b_sc01_ort_img_atm.bsq');
    
%    envi = enviread('/cise/homes/msnia/neon/midday/f100910t01p00r04rdn_b/f100910t01p00r04rdn_b_sc01_ort_img_atm.bsq');
    %envi = enviread('/cise/homes/msnia/neon/morning/f100910t01p00r04rdn_b_NEON-L1G/f100910t01p00r04rdn_b_sc01_ort_flaashreflectance_img');
%else
%    cd('/home/scidb/zproject/neonDSR/code/matlab/');
%    envi = enviread('/home/users-share/allFlights/f100910t01p00r03rdn_b_NEON-L1G/f100910t01p00r03rdn_b_sc01_ort_flaashreflectance_img');
%end

envi = enviread(envi_file_path);

%checkXYsHaveUniformStepSizes(envi);

envi.z = double(envi.z);

for j = 1: size(envi.z, 2)
    for i = 1: size(envi.z, 1)
        if i == 300 && j == 300
        disp('w')
        end
        envi.z(i, j, :) = scalePixel(envi.z(i,j,:));
    end
end


end

