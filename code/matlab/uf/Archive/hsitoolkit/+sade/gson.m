% Returns an instance of Google's JSON (GSON) parser/emitter.
% This will add the necessary jar file to the java dynamic classpath if not
% already present, which may result in java objects going missing.
function g = gson()

if ~exist('com.google.gson.Gson', 'class');    
    mypath = fileparts(mfilename('fullpath'));
    gson_jar = fullfile(mypath, 'gson-2.2.2.jar');
    javaaddpath(gson_jar);
end
g = com.google.gson.Gson;
