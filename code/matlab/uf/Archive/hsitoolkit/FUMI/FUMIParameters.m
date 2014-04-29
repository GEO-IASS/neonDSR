function [parameters] = FUMIParameters()

parameters.u            = 0.01; %Larger value means less weight on reconstruction error more weight on volume (bringing endmembers closer together)
parameters.gamma        = .1;     %Larger weight should mean fewer endmembers
parameters.changeThresh = 1e-6;  %When to stop.
parameters.M            = 10;    %Initial number of endmembers
parameters.iterationCap = 1000;  %When to stop.
parameters.endmemberPruneThreshold = 1e-10; %When to prune an endmember
parameters.produceDisplay          = 1;
parameters.initEM       = nan;   %This randomly selects parameters.M initial endmembers from the input data
parameters.tWeight      = 2;     %weight of 1 target pixel to 1 background pixel, how to weight the target points wrt to background, larger values means more weight for target over background
parameters.beta         = 2;

parameters.sum_to_one = false; 
  % if true, constrain proportions to sum to 1, if false, sum <= 1

parameters.physically_correct_endmembers = true;
  %  if true, use quadratic program to solve for [0-1] constrained endmembers,
  %   otherwise solve directly (may be < 0 or > 1)
