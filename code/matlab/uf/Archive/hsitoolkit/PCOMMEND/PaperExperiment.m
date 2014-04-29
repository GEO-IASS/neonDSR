function [SAD, SID, ESQ, PSQ] = PaperExperiment(X, Etrue, Ptrue);

addpath('/Users/alina/Documents/MATLAB/PCOMMEND');
addpath('/Users/alina/Documents/MATLAB/SPICE');
addpath('/Users/alina/Documents/MATLAB/demo_vca');

[PCOMMENDParameters] = PCOMMEND_Parameters();
[SPICEParams] = SPICEParameters();

noise = [0.01; 0.1; 0.25];
for mm = 1:length(noise)
    
    for i = 1:3
            
        X = Etrue'*Ptrue;
        X = X + randn(size(X))*noise(mm);
    
        [Evca] = vca(X,'Endmembers', 6);
        [Espice, Pspice] = SPICE(X, SPICEParams);
        [Epcommend,Ppcommend,U,~]=PCOMMEND(X',PCOMMENDParameters);
        Ep = [];
        Pp = [];
        for j = 1:length(Epcommend)
            Ep = vertcat(Ep, Epcommend{j});
            Pp = horzcat(Pp, Ppcommend{j}.*repmat(U(j,:)', [1, 3]));
        end
        
        SAD(mm,i,1) = computeSADSet(Etrue, Ep);
        SAD(mm,i,2) = computeSADSet(Etrue, Evca');
        SAD(mm,i,3) = computeSADSet(Etrue, Espice');
        
        SID(mm,i,1) = computeSIDSet(Etrue, Ep);
        SID(mm,i,2) = computeSIDSet(Etrue, Evca');
        SID(mm,i,3) = computeSIDSet(Etrue, Espice');
        
        [ESQ(i,1), PSQ(i,1)] = computeSQSet(Etrue, Ptrue, Ep, Pp');
        [ESQ(i,2), PSQ(i,2)] = computeSQSet(Etrue, Ptrue, Espice', Pspice');
    end
    
end

end

function [ESQ, PSQ] = computeSQSet(Etrue, Ptrue, Eest, Pest)
    ESQ = 0;
    PSQ = 0;
    for i = 1:size(Eest)
        for j = 1:size(Etrue)
            ssE(j) = (Etrue(j,:)- Eest(i,:))*(Etrue(j,:)- Eest(i,:))';
            ssP(j) = (Ptrue(j,:)- Pest(i,:))*(Ptrue(j,:)- Pest(i,:))';
            ss(j) = ssE(j) / length(Etrue(j,:)) + ssP(j) / length(Ptrue(j,:));
        end
        [val, loc] = min(ss);
        ESQ = ESQ + ssE(loc);
        PSQ = PSQ + ssP(loc);
        Etrue = Etrue(setdiff([1:size(Etrue,1)], loc), :);   
        Ptrue = Ptrue(setdiff([1:size(Ptrue,1)], loc), :);   
    end
end


function [SAD] = computeSADSet(Etrue, Eest)
    SAD = 0;
    for i = 1:size(Eest)
        for j = 1:size(Etrue)
            ss(j) = computeSAD(Etrue(j,:), Eest(i,:));
        end
        [val, loc] = min(ss);
        SAD = SAD + val;
        Etrue = Etrue(setdiff([1:size(Etrue,1)], loc), :);
    end
end

function [SAD] = computeSAD(Etrue, Eest)
    denom = sqrt(sum(Etrue.*Etrue)*sum(Eest.*Eest));
    num   = Etrue*Eest';
    SAD   = acos(num/denom);
end

function [SID] = computeSIDSet(Etrue, Eest)
    SID = 0;
    for i = 1:size(Eest)
        for j = 1:size(Etrue)
            ss(j) = computeSID(Etrue(j,:), Eest(i,:));
        end
        [val, loc] = min(ss);
        SID = SID + val;
        Etrue = Etrue(setdiff([1:size(Etrue,1)], loc), :);    
    end
end

function [SID] = computeSID(Etrue, Eest)
    rat1  = Etrue./Eest;
    rat2  = Eest./Etrue;
    SID   = sum(Etrue.*log(rat1)) + sum(Eest.*log(rat2));
end