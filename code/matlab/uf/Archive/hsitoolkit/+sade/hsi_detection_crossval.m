% HSI Detection Crossvalidation
% [confmaps, params] = sade.hsi_detection_crossval(images, train, test, ...)
% images: Cell array of HSI images. Image structures must be provided if
%         the 'targetfilter' parameter will be provided, but otherwise just
%         the image data is fine. Filenames are fine too.
%
% train: Function handle with the following signature:
%        params = train(images, truth, ...)
%        'images' and 'truthmaps' will be cell arrays containing one or
%        more image arrays (and associated truth). The images may
%        have regions with NaN values representing data not present in this
%        training fold. If the 'extra' argument is provided, its elements
%        will be provided as additional training arguments.
%
% test: Function handle with the following signature:
%       confmap = test(image, params)
%       Evaluate the trained parameters on the image. A single image array
%       will be provided.
% 
% The following optional arguments must be provided as name/value pairs.
%
% foldmaps: Cell array of masks of the same size as 'images'. The mask
%    values should range from 1 to N to indicate fold membership for N-fold
%    crossvalidation. Pixels labeled 0 (or other weird values) will be
%    excluded from crossvalidation entirely. 
%    If fold maps are not provided, each image will be treated as one fold.
%
% truth: Data indicating target positions. (Usually a structure). Optional;
%    may be inferred from the HSI data structures. See
%    sade.parse_hsi_groundTruth.
% targetfilter: A filter to determine which targets are presented for
%    training. See sade.hsi_target_filter
%
% extra: A cell array of additional arguments to be provided to the 'train'
%    function. 

function [confmaps, params] = hsi_detection_crossval(varargin)

p = inputParser;
p.addRequired('images');
p.addRequired('train');
p.addRequired('test');
p.addParamValue('foldmaps', {}, @iscell);
p.addParamValue('truth', {}, @iscell);
p.addParamValue('targetfilter', {});
p.addParamValue('extra', {}, @iscell);
p.parse(varargin{:});
args = p.Results;

% Get image data and possibly truth data.
images = cell(size(args.images));
image_truth = cell(size(args.images));
for i=1:numel(args.images)
    if ischar(args.images{i})
        matfile = load(args.images{i});
        hsi = matfile.hsi;
    else
        hsi = args.images{i};
    end
    if isstruct(hsi)
        images{i} = hsi.Data;
        image_truth{i} = sade.parse_hsi_groundTruth(hsi.groundTruth);
    else
        images{i} = hsi;
        image_truth{i} = struct([]);
    end
end

% Replace truth data if provided

if ~isempty(args.truth)
    for i=1:numel(args.truth)
        if ~isempty(args.truth{i})
            image_truth{i} = args.truth{i};
        end
    end
end

% Apply filters - adds "is_target" field to truth items.

if ~isempty(args.targetfilter)
    for i=1:numel(image_truth)
        targets = sade.hsi_target_filter(image_truth{i}, args.targetfilter);
        for j=1:numel(image_truth{i})
            image_truth{i}(j).is_target = targets(j);
        end
    end
end

% Determine crossvalidation strategy: Image-based or region-based
if isempty(args.foldmaps)
    [confmaps, params] = image_crossval(images, image_truth, args.train, args.test, args.extra);
else
    % Load fold maps if filenames were provided.
    foldmaps = cell(size(args.foldmaps));
    for i = 1:numel(args.foldmaps)
        if isnumeric(args.foldmaps{i})
            foldmaps{i} = args.foldmaps{i};
        elseif ischar(args.foldmaps{i})
            foldmaps{i} = imread(args.foldmaps{i});
        end
    end
    [confmaps, params] = region_crossval(images, image_truth, foldmaps, args.train, args.test, args.extra);
end

% Done.
end

function [confmaps, params] = image_crossval(images, image_truth, train, test, extra)
% Each image represents one crossvalidation fold. 
% Train on all images but one, evaluate test function on that one.
fprintf('Image-based crossval (one fold per image), %d images.\n', numel(images));
confmaps = cell(size(images));
params = cell(size(images));
for i=1:numel(images)
    fprintf('Crossval: Training %d of %d\n', i, numel(images));
    training_img = images([1:i-1 i+1:end]);
    training_gt  = image_truth([1:i-1 i+1:end]);
    test_img = images{i};
    params{i} = feval(train, training_img, training_gt, extra{:});
    fprintf('Crossval: Testing %d of %d\n', i, numel(images));
    confmaps{i} = feval(test, test_img, params{i});
end
end

function [confmaps, params] = region_crossval(images, image_truth, foldmaps, train, test, extra)
% A bit more complicated. Each image contains pixels from (potentially) all
% folds. This means that for each fold, the training function will see
% (most of) every image. The test function will see all of every image each
% time, but only the confidences produced in the test regions will be
% recorded. The output confidence maps will therefore be mosaics of
% confidence maps from multiple training sessions. 

% First determine the number of folds. Also build empty confidence maps and
% 3D image masks. 
N = 1;
confmaps = cell(size(images));
bigmasks = cell(size(foldmaps));
for i=1:numel(foldmaps)
    N = max(1, max(foldmaps{i}(:)));
    [R,C,B] = size(images{i});
    confmaps{i} = nan(R,C);
    bigmasks{i} = repmat(foldmaps{i}, [1 1 B]);
end
params = cell(1,N);
fprintf('Region-based crossval (%d folds), %d images.\n', N, numel(images));

% Identify fold regions for each truth item.
for i = 1:numel(image_truth)
    for t = 1:numel(image_truth{i})
        r = image_truth{i}(t).rowindices;
        c = image_truth{i}(t).colindices;
        image_truth{i}(t).fold = foldmaps{i}(r,c);
    end
end

for n=1:N    
    fprintf('Crossval: Training %d of %d\n', n, N);
        
    % Remove the current fold's data from the images.    
    train_images = images;
    for i = 1:numel(images)
        train_images{i}(bigmasks{i} == n) = nan;
    end
    % Remove groundtruth items from the test fold area.    
    train_truth = cell(size(image_truth));
    for i=1:numel(image_truth)
        truth_folds = [image_truth{i}.fold];
        train_truth{i} = image_truth{i}(truth_folds ~= n);        
    end    
    % Do training and testing
    params{n} = feval(train, train_images, train_truth, extra{:});
    fprintf('Crossval: Testing %d of %d\n', n, N);
    for i=1:numel(images)
        test_conf = feval(test, images{i}, params{n});
        % Only keep the test fold's confidences.
        test_fold = foldmaps{i} == n;
        confmaps{i}(test_fold) = test_conf(test_fold);
    end
end
end
