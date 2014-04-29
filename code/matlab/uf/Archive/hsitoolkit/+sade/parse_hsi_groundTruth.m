% Rearranges the groundTruth structure of an HSI image into something
% slightly different. Converts a 1x1 struct with 'Targets_' fields of
% length N to a 1xN struct whose fields lack the 'Targets_' prefix and are
% lowercased.
function gt = parse_hsi_groundTruth(groundTruth)

if isfield(groundTruth, 'groundTruth')
    % An HSI structure was passed in. Extract GT.
    groundTruth = groundTruth.groundTruth;
end

if numel(groundTruth) > 1
    % Careful, don't try to do it more than once.
    gt = groundTruth;
    return;    
end

orig_fields = fieldnames(groundTruth);
gt = struct([]);

for f = 1:numel(orig_fields)
    values = groundTruth.(orig_fields{f});
    new_name = renamify(orig_fields{f});
    for i=1:numel(values)        
        if iscell(values)
            v = values{i};
        else
            v = values(i);
        end
        gt(i).(new_name) = v;
    end
end
end

function name = renamify(field)
prefix = 'Targets_';
P = numel(prefix);
if numel(field) < P
    name = field;
elseif isequal(field(1:P), prefix)
    name = field(P+1:end);
end
name = lower(name);
end
