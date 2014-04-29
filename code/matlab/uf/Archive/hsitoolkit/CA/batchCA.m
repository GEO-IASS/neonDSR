function [Results, CTrace]= batchCAPCOMMEND(InputData);

NumIterations = 1000;
% saveFrequency = 1000;
% saveName = 'batchCAPCOMMEND3_';
[parameters] = CAPCOMMEND_Parameters();

CTrace = zeros(1,NumIterations);
for i = 1:NumIterations
    disp(['Iteration ', num2str(i), ' of ', num2str(NumIterations)]);
    [E,P,U,obj_func]=CAPCOMMEND(InputData,parameters);
    Results{i}.E = E;
    Results{i}.P = P;
    Results{i}.U = U;
    Results{i}.obj_func = obj_func;
    Results{i}.parameters = parameters;
    CTrace(i) = length(E);
%     CTrace(i)
%     if(mod(i, saveFrequency) == 0)
%         disp('Saving....');
%         save([saveName, num2str(j)], 'Results', 'CTrace');
%     end
end
