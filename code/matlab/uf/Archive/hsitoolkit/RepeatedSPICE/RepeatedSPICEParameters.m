function [Parameters] = RepeatedSPICEParameters()
%   This function sets possible values for the  parameters to be used for
%       the RepeatedSPICE algorithm
%
%     Parameters -Struct that contains the fields:
%                1. RepeatedParameters: a 1xN matrix of structs which has the parameters
%                       for SPICE to run with. If only one set of
%                       parameters is to be used, then this should be only
%                       one struct
%                2. iterationsPerParameters: The number of iterations that
%                       SPICE is to be run for each set of parameters.
%                3. saveEndmembers: set to 1 if endmembers found is to be
%                       saved.
%                4. saveEndmemberFilePath: File Path for where to save the
%                       endmember result if wanted.

Parameters.RepeatedParameters = SPICEParameters;

Parameters.iterationsPerParameters = 50;

Parameters.saveEndmembers = 0;
Parameters.saveEndmemberFilePath = '';

end