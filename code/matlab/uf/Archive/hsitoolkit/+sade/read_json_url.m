% parsed_data = sade.read_json_url(url)
%
% Reads from a given URL, which should return JSON data.
% Will throw some sort of error or another if the URL can't be read or the
% GSON parser can't eat what comes out of it.
function parsed_data = read_json_url(url)

parser = sade.gson;
HashMap = java.lang.Class.forName('java.util.HashMap');

data = urlread(url);

parsed_data = parser.fromJson(data, HashMap);
