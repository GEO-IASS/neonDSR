% details = sade.get_experiment_details(url)
% Get an experiment's details structure.
% The return value is in the form of a Java hashmap.
%
% If using the default SADE server (see sade.DEFAULT_SADE), you can
% provide the numeric ID instead of the URL.
function experiment = get_experiment_details(url)

% Pass java objects through untouched, except for strings.
if isjava(url)
    if isa(url, 'java.lang.String')
        url = char(url);
    else
        experiment = url;
        return;
    end
end

% Convert experiment ID to url
if isnumeric(url)
    url = sprintf('%s/experiment/%d', sade.DEFAULT_SADE, url);
end

% If provided with the normal experiment URL, convert to the JSON url
if url(end) == '/'
    url(end) = [];
end
if ~isequal(url(end-5:end), '.json')
    url = [url '.json'];
end

experiment = sade.read_json_url(url);
