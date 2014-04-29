% sade.download_experiment(url, [force=false])
% url is the URL of the experiment on the SADE server. Its numeric value or
% a pre-fetched copy of the experiment details are also valid.
%
% Downloads dataset and auxiliary files associated with this experiment to
% the current directory. 
% If 'force' is false, only missing files will be downloaded.
function files = download_experiment(url, force)

if ~exist('force', 'var')
    force = false;
end

if isjava(url) && ~isa(url, 'java.lang.String')
    experiment = url;
else
    experiment = sade.get_experiment_details(url);
end

datasets = experiment.get('datasets').iterator();
files = struct('data', {});
i = 0;
while datasets.hasNext()    
    ds = datasets.next();
    i = i+1;
    data_url = ds.get('data_url');
    files(i).data = get_url(data_url, force, 'Dataset: %s', char(ds.get('name')));
    aux = ds.get('auxfiles');
    auxkeys = aux.keySet.toArray;
    for j=1:numel(auxkeys)
        auxfile = char(aux.get(auxkeys(j)));
        auxname = genvarname(char(auxkeys(j)));        
        files(i).(auxname) = get_url(auxfile, force, 'Auxiliary file: %s', auxname);
    end
end
end

function fullname = get_url(url, force, format, varargin)
[~, base, ext] = fileparts(url);
filename = [base ext];
fullname = fullfile(pwd, filename);

info_str = sprintf(format, varargin{:});
if ~exist(fullname, 'file') || force
    fprintf('Downloading %s: %s\n', info_str, filename);
    urlwrite(url, fullname);
else
    fprintf('Already downloaded %s: %s.\n', info_str, filename);
end
end