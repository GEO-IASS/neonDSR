
function  [P] = unmix_qpas_LMM_LessOrEq(X, E, ErrMask,OptParams) %gammaConst, PF, parameters)
%function [P] = unmix_qpas_MacMic(X, E, OptParams); %gammaConst, PF, parameters)

ConstErrCount  = 0;
Const2ErrCount = 0;
D              = size(X, 1);
N              = size(X, 2);
warning('off', 'all');
options = optimset('Display', 'off', 'LargeScale', 'on');

%%%%% ADD THIS BACK IN LATER %%%%%%%
%gammaVecs =  (gammaConst./sum(PF));


P         = zeros(OptParams.M, OptParams.N);
NoErrMask = isempty(ErrMask);
L         = vertcat(E, ones(1, OptParams.M)); %[Ep;ones]<=[X,; 1]
NConst    = D;
H         = 2 * (E'* E);
parfor i = 1:OptParams.N
    if(NoErrMask | ErrMask(i) > 0.01) %RELIES ON LAZY EVALUATION
        k               = vertcat(X(:, i), 1);
        C               = -2 * E'* X(:,i);%+gammaVecs)';
        %%% XXX YOU ARE HERE.  FIGURE OUT HOW TO PASS ARGUMENTS %%%
        qpas_ans        = qpas(H, C, L, k, [], [], OptParams.lb, OptParams.ub, 0);
        qpas_sum        = sum(qpas_ans);
        ConstPerErr     = max(0,qpas_sum-1)*100;
        ConstErr        = ConstPerErr > OptParams.ConstErrFlag; %set if constraints are not met
        DiffRhsLhs      = k-L*qpas_ans;
        Const2Err       = (DiffRhsLhs < 0);
        NConst2Err      = sum(Const2Err);
        AConst2Err      = DiffRhsLhs.*Const2Err;
        TConst2Err      = sum(AConst2Err);
        MConst2Err      = max(AConst2Err(:));
        Const2Failed    = MConst2Err > 0.01;
        if (ConstErr)
            %ConstErrCount = ConstErrCount + 1;
            %keyboard
            %disp('constraint error detected and corrected');
            P(:, i)       = quadprog(H, C, L, k, [], [], OptParams.lb, [], [], options);
        elseif(Const2Failed)
            %Const2ErrCount = Const2ErrCount + 1;
            %disp('constraint 2 error detected and corrected');
            %fprintf('TotalError %f  Max Error %f \n', TConst2Err, MConst2Err);
            P(:, i)       = quadprog(H, C, L, k, [], [], OptParams.lb, [], [], options);
        else
            P(:, i)       = qpas_ans;
        end
    end
end
P(P<0) = 0;

