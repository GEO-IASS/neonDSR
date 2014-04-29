% url = sade.DEFAULT_SADE
% Returns the base URL for the default SADE server.
% To change the address for this MATLAB session, call this function with
% the new URL as an argument.
function url = DEFAULT_SADE(new_default)
persistent sade_url
if isempty(sade_url)
    % TODO: This is the demo server. Please update this file when a real
    % server is configured.
    sade_url = 'http://elderberry.cise.ufl.edu:8096/sade';
end
if nargin > 0
    sade_url = new_default;
end
url = sade_url;
end
