% targets = sade.hsi_target_filter(groundTruth, filter)
% Applies a target filter to a set of ground truth data.
% The output will be a logical array with true values for ground truth
% objects that should be considered targets based on this filter.
%
% Ground truth may be provided in the format used in HSI mat file
% structures or simply as a structure array. The function
% "sade.parse_hsi_groundtruth" will be used to interpret the data.
%
% Filters may be provided as a cell array of 1x1 structs. Each of these
% structs may have some number of fields corresponding to fields in the
% ground truth data. A target matches the filter if it matches any of the
% structs; that is, if each of the fields in the struct is equal to the
% corresponding field in the ground truth. Items that match at least one
% of the structs will be marked as 'true' in the output. 
% If the cell array is empty, all objects are considered targets.
%
% A Java List of Maps (such as one read from a SADE HSI Detection
% experiment's JSON data) is acceptable as well.
% 
% Example filter: All brown objects, plus blue objects of size 6.
% JSON: [{'type': 'brown'}, {'type': 'blue', 'size': 6}]
% MATLAB: {struct('type', 'brown'), struct('type', 'blue', 'size', 6)}
%
function targets = hsi_target_filter(groundTruth, filter)
% Ground truth with modified names.
gt = sade.parse_hsi_groundTruth(groundTruth);

% Targets starts off all false. Filters add items to it.
targets = false(size(gt));

% Convert to cell array of structs if given list of maps
if isjava(filter)
    filter = convert_java_filter(filter);
end

if isempty(filter)
    targets(1:end) = true;
else
    for f=1:numel(filter)
        % Any of the filter elements may enable a target.
        % Doing so requires that all of the fields in the filter
        % element are equal to the equivalent fields in the target info.
        check_fields = fieldnames(filter{f});
        for i=1:numel(targets)
            checks = false(size(check_fields));
            for c=1:numel(check_fields)
                if ~isfield(gt, check_fields{c})
                    continue;
                end
                if isequal(gt(i).(check_fields{c}), ...
                        filter{f}.(check_fields{c}))
                    checks(c) = true;
                end
            end
            if all(checks)
                targets(i) = true;
            end
        end
    end
end

end


function filter = convert_java_filter(jfilter)

filter = {};

for i=0:jfilter.size()-1
    jf_elem = jfilter.get(i);
    f_elem = struct();
    keys = jf_elem.keySet().toArray;
    for k=1:numel(keys)
        field = char(keys(k));
        java_value = jf_elem.get(keys(k));
        if isa(java_value, 'java.lang.String')
            value = char(java_value);
        else
            value = java_value;
        end
        f_elem.(field) = value;
    end
    filter{end+1} = f_elem; %#ok<AGROW>
end

end