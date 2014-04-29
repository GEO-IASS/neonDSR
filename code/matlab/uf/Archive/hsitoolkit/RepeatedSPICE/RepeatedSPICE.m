function [endmembers] = RepeatedSPICE(hylidImage, Parameters)
% Run SPICE numerous times for sets of parameters and save all the
% endmembers found.
% 
% Syntax: [endmembers] = RepeatedSPICE(hylidImage,Parameters)
% 
% Inputs:
%     hylidImage: subImage created by the function createSubImage or has a
%       Data field for SPICE to be run on.
%     Parameters -Struct that contains the fields:
%                1. RepeatedParameters: a 1xN matrix which has the parameters
%                       for SPICE to run with. This can be only one set of
%                       parameters if SPICE is only to be run on one set of
%                       parameters.
%                2. iterationsPerParameters: The number of iterations that
%                       SPICE is to be run for each set of parameters.
%                3. saveEndmembers: set to 1 if endmembers found is to be
%                       saved.
%                4. saveEndmemberFilePath: File Path for where to save the
%                       endmember result if wanted.
% Output: endmembers - NxM Matrix of M endmembers with N spectral bands.

endmembers = [];

for i=1:size(Parameters.RepeatedParameters,2)%Run SPICE for each parameter set
    for j=1:Parameters.iterationsPerParameters
        [endmem, ~] = SPICE(reshapeImage(double(hylidImage.Data)),Parameters.RepeatedParameters(i));
        endmembers = [endmembers endmem];
    end  
end

if(Parameters.saveEndmembers)%Save endmembers
    filename = fullfile(Parameters.saveEndmemberFilePath,'RepeatedSPICEEndmembers.mat');
    save(filename,'endmembers');
end


end