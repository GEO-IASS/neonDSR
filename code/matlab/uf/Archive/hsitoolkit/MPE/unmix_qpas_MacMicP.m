
function  [P] = unmix_qpas_MacMicP(X, E, rVec, OptParams, ErrMask) %gammaConst, PF, parameters)
%function [P] = unmix_qpas_MacMic(X, E, OptParams); %gammaConst, PF, parameters)

ConstErrCount  = 0;
Const2ErrCount = 0;
NoErrMask      = isempty(ErrMask);
D              = size(X, 1);
N              = size(X, 2);
warning('off', 'all');
options = optimset('Display', 'off', 'LargeScale', 'on');

%%%%% ADD THIS BACK IN LATER %%%%%%%
%gammaVecs =  (gammaConst./sum(PF));


P        = zeros(OptParams.M + 1, OptParams.N);


L1 = horzcat(E, zeros(D, 1)); %[E 0]*P<=X; EpL <= X
L2 = -horzcat(E, ones(D, 1)); %-[E 1]*P<=-X EpL+EpN >=X
L  = vertcat(L1, L2);
NConst = 2*D;
parfor i = 1:OptParams.N
    if(NoErrMask | ErrMask(i) > 0.01) %RELIES ON LAZY EVALUATION
     
        %if (TransVar)
            EwithMicro  = [E, rVec(:,i)]; %%MAKE MORE MEMORY EFFICIENT LATER
            H           =  2 * (EwithMicro'* EwithMicro);
        %end
		
        k               = vertcat(X(:, i), -X(:, i));
        C               = -2 * EwithMicro'* X(:,i);%+gammaVecs)';
        qpas_ans        = qpas(H, C, L, k, OptParams.AeqR, OptParams.beqR, OptParams.lbR, OptParams.ubR, 0);
        qpas_sum        = sum(qpas_ans);
        ConstPerErr     = abs(1-qpas_sum)*100;
        ConstErr        = ConstPerErr > OptParams.ConstErrFlag; %set if constraints are not met
        DiffRhsLhs      = k-L*qpas_ans;
        Const2Err       = (DiffRhsLhs < 0);
        NConst2Err      = sum(Const2Err);
        AConst2Err      = DiffRhsLhs.*Const2Err;
        TConst2Err      = sum(AConst2Err);
        MConst2Err      = max(AConst2Err(:));
        Const2Failed    = MConst2Err > 0.01;
        if (ConstErr)
            %ConstErrCount = ConstErrCount + 1; %disp('constraint error detected and corrected');
            P(:, i)       = quadprog(H, C, L, k, OptParams.AeqR, OptParams.beqR, OptParams.lbR, [], [], options);
        elseif(Const2Failed)
            %Const2ErrCount = Const2ErrCount + 1;
            disp('constraint 2 error detected and corrected');
            fprintf('TotalError %f  Max Error %f \n', TConst2Err, MConst2Err);
            P(:, i)       = quadprog(H, C, L, k, OptParams.AeqR, OptParams.beqR, OptParams.lbR, [], [], options);
        else
            P(:, i)       = qpas_ans;
        end
    end
end

%fprintf('%s%s:  %d\n', 'Number of Constraints that can', 't get no Na na na nanana na satis faction\n', ConstErrCount);
P(P<0) = 0;

