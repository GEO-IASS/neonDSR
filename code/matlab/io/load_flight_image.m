function envi = load_flight_image( envi_file_path )
% Read ENVI file and Normalize ata reflectance range = [-32724, +32762]

envi = enviread(envi_file_path);
envi.z = double(envi.z);

%checkXYsHaveUniformStepSizes(envi);
end

