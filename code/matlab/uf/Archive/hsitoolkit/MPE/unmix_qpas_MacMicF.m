
function [F] = unmix_qpas_MacMicF(X, E, OptParams, ErrMask); %gammaConst, PF, parameters)
%function [F] = unmix_qpas_MacMicF(X, E,  OptParams); %gammaConst, PF, parameters)

ConstErrCount = 0;
N             = size(X, 2);
NoErrMask     = isempty(ErrMask);
warning('off', 'all');
options = optimset('Display', 'off', 'LargeScale', 'on');

%%%%% ADD THIS BACK IN LATER %%%%%%%
%gammaVecs =  (gammaConst./sum(PF));


H = 2*(E'*E);
C = -2*E'*X;
%P = zeros(OptParams.M, N);
%parfor i = 1:OptParams.N
parfor i = 1:N
    if(NoErrMask | ErrMask(i) > 0.01) %RELIES ON LAZY EVALUATION
        %%%SOLVE QUADRATIC PROGRAM WITH qpas AND MAKE SURE IT SATISFIES
        %%%CONSTRAINTS
        qpas_ans    = qpas(H, C(:,i), [], [], OptParams.Aeq, OptParams.beq, OptParams.lb, OptParams.ub, 0);
        qpas_sum    = sum(qpas_ans);
        ConstPerErr = abs(1-qpas_sum)*100;
        ConstErr    = (ConstPerErr > OptParams.ConstErrFlag); %set if constraints are not met
        
        %%%IF DOESN'T SATISFY CONSTRAINTS, SOLVE WITH quadprog
        if (ConstErr)
            %ConstErrCount = ConstErrCount + 1; %disp('constraint error detected and corrected');
            F(: , i)      = quadprog(H, C(:,i), [], [], OptParams.Aeq, OptParams.beq, OptParams.lb, [], [], options);
        else
            F(:, i)       = qpas_ans;
        end
    end
end
%fprintf('%s%s:  %d\n', 'Number of Constraints that can', 't get no satis faction', ConstErrCount);
F(F<0) = 0;

