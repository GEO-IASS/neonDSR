
 function [P] = unmix_qpas_MacMic(X, E, rVec, OptParams); %gammaConst, PF, parameters)
%function [P] = unmix_qpas_MacMic(X, E, OptParams); %gammaConst, PF, parameters)

ConstErrCount = 0;
N             = size(X, 2);
warning('off', 'all');
options = optimset('Display', 'off', 'LargeScale', 'on');

%%%%% ADD THIS BACK IN LATER %%%%%%%
%gammaVecs =  (gammaConst./sum(PF));

if(~isempty(rVec))
    P        = zeros(OptParams.M + 1, OptParams.N);
    TransInv = (size(rVec, 2) == 1);
    TransVar = 1-TransInv;
    fprintf('Input Proportion vector size is %d by %d\n', size(P, 1), size(P, 2));
    if (TransInv);
        EwithMicro = [E, rVec];
        H          =  2 * (EwithMicro'* EwithMicro);
    end
    
    for i = 1:OptParams.N
        %parfor i = 1:OptParams.N
        if (TransVar)
            EwithMicro  = [E, rVec(:,i)]; %%MAKE MORE MEMORY EFFICIENT LATER
            H           =  2 * (EwithMicro'* EwithMicro);
        end
        C               = -2 * EwithMicro'* X(:,i);%+gammaVecs)';
        qpas_ans        = qpas(H, C, [], [], OptParams.AeqR, OptParams.beqR, OptParams.lbR, OptParams.ubR, 0);
        qpas_sum        = sum(qpas_ans);
        ConstPerErr     = abs(1-qpas_sum)*100;
        ConstErr        = (ConstPerErr > OptParams.ConstErrFlag); %set if constraints are not met
        if (ConstErr)
            ConstErrCount = ConstErrCount + 1; %disp('constraint error detected and corrected');
            P(:, i)       = quadprog(H, C, [], [], OptParams.AeqR, OptParams.beqR, OptParams.lbR, [], [], options);
        else
            P(:, i)       = qpas_ans;
        end
        
    end
else
    H = 2*(E'*E);
    C = -2*E'*X;
    P = zeros(OptParams.M, N);
    %parfor i = 1:OptParams.N
    for i = 1:N
        %%%SOLVE QUADRATIC PROGRAM WITH qpas AND MAKE SURE IT SATISFIES
        %%%CONSTRAINTS
        qpas_ans    = qpas(H, C(:,i), [], [], OptParams.Aeq, OptParams.beq, OptParams.lb, OptParams.ub, 0);
        qpas_sum    = sum(qpas_ans);
        ConstPerErr = abs(1-qpas_sum)*100;
        ConstErr    = (ConstPerErr > OptParams.ConstErrFlag); %set if constraints are not met
        
        %%%IF DOESN'T SATISFY CONSTRAINTS, SOLVE WITH quadprof
        if (ConstErr)
            ConstErrCount = ConstErrCount + 1; %disp('constraint error detected and corrected');
            P(: , i) = quadprog(H, C(:,i), [], [], OptParams.Aeq, OptParams.beq, OptParams.lb, [], [], options);
        else
            P(:, i) = qpas_ans;
        end
    end
end
fprintf('Output Proportion vector size is %d ', size(P));fprintf('\n');
fprintf('%s%s:  %d\n', 'Number of Constraints that can', 't get no satis faction', ConstErrCount);
P(P<0) = 0;

