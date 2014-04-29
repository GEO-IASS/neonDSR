% [confmaps, params] = sade.run_hsi_detection_experiment(url, train, test, ...)
%
% Retrieves experiment information, downloads the data files to the current
% directory (if not yet present), runs crossvalidation on them, and saves
% the confidence maps to files with names based on the train function name.
% For more fine-grained control, see sade.hsi_detection_crossval.
%
% url: A URL indicating a SADE HSI Detection experiment. A numeric ID may
%      be used, which will attempt to load the experiment from the default
%      SADE server (see sade.DEFAULT_SADE).
%
% train: Function handle with the following signature:
%        params = train(images, truth, ...)
%        'images' and 'truth' will be cell arrays containing one or
%        more image arrays and associated truth structures. The images may
%        have regions with NaN values representing data not present in this
%        training fold. If the 'extra' argument is provided, its elements
%        will be provided as additional training arguments.
%
% test: Function handle with the following signature:
%       confmap = test(image, params)
%       Evaluate the trained parameters on the image. A single image array
%       will be provided.
% 
% Any additional arguments will be passed directly to
% sade.hsi_detection_crossval
function [confmaps, params] = run_hsi_detection_experiment(url, train, test, varargin)

experiment = sade.get_experiment_details(url);
assert(isequal(char(experiment.get('type')), 'HSI_TD'), 'Wrong experiment type');

files = sade.download_experiment(experiment);

% Assemble image files and crossval folds (if available)
N = numel(files);
images = cell(1,N);
folds = cell(1,N);

for i=1:N
    images{i} = files(i).data;
    if isfield(files, 'crossval_fold_map') && ...
            ~isempty(files(i).crossval_fold_map)
        folds{i} = files(i).crossval_fold_map;
    end
end

% Check for fold maps
nofolds = cellfun(@isempty, folds);
if any(nofolds)
    warning('No crossvalidation fold maps provided, using image-based crossval.');
    folds = {};
end

% Extract target filter
target_filter = experiment.get('scorer_params').get('target_filter');

% Run crossval!
[confmaps, params] = sade.hsi_detection_crossval(images, train, test, ...
    'foldmaps', folds, 'targetfilter', target_filter, varargin{:});

% Save the confidence maps.
suffix = genvarname(func2str(train));

for i=1:N    
    conf = confmaps{i}; %#ok<NASGU> used in SAVE below
    [outdir, outbase] = fileparts(images{i});
    conf_file = fullfile(outdir, [outbase '_' suffix '_conf.mat']);
    fprintf('Saving confidence map %s...\n', conf_file);
    save(conf_file, 'conf');        
end
