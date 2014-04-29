function [err, match] = computeError(Etrue, Eest)


diff = pdist2(Etrue, Eest);
[V, match] = min(diff, [], 2);
if(length(match) ~= size(Etrue,1))
    error('this is not coded up')
    keyboard;
end

err = sum(V.^2);