function [P, F, Error, RSSsum] = unmixC4MModel2(endmembers, data, dataW, mu, refAlbLookupStruct)

D = size(data,1);
N = size(data,2);
M = size(endmembers, 2);
P = zeros(M+1, N);
F = zeros(M, N);

options = optimset('Display', 'off', 'LargeScale', 'off');

%set up constraint matrices
A = vertcat(vertcat(-1*eye(M), ones([1, M]), -1*ones([1, M])));
b = vertcat(vertcat(zeros([M, 1]), 1), -1);

Ap = vertcat(vertcat(-1*eye(M+1), ones([1, M+1]), -1*ones([1, M+1])));
bp = vertcat(vertcat(zeros([M+1, 1]), 1), -1);

W = zeros(D,M);
parfor i=1:M
    W(:,i) =  lookupAlbedo2(endmembers(:,i), refAlbLookupStruct);
end

%update F
H = (2*(W'*W));
parfor i=1:N
    c = (-2*(dataW(:,i)'*W))';
%     F(:,i) = quadprog(H, c, A, b, [], [], [], [], [], options);
    F(:,i) = qpas(H, c, A, b, [], [], [], [], 0);
end

if sum(sum(F<0)) ~= 0
    if sum(sum(F<-1e-12)) ~= 0
        fprintf('A non-zero proportion (F) was found\n');
    end
    F(F<0) = 0;
end

rVec = zeros(D,N);
parfor i = 1:N
    rVec(:,i) = convertToReflectance2(W*F(:,i), refAlbLookupStruct);
end

%update P
parfor i = 1:N
EwithMicro = [endmembers, rVec(:,i)];
H = 2*(EwithMicro'*EwithMicro);
    c = (-2*(data(:,i)'*EwithMicro))';

    P(:,i) = qpas(H, c, Ap, bp, [], [], zeros([M+1,1]), [], 0);
end

if sum(sum(P<0)) ~= 0
    if sum(sum(P<-1e-12)) ~= 0
%         fprintf('A non-zero proportion (P) was found\n');
%         disp(strcat('Number of Problems: ',num2str(sum(sum(P<-1e-12)))));
        problemPixels=find(sum(P<-1e-12 | P>(1+1e-12))>0);
        
        fixing_rVec = rVec(:,problemPixels);
        fixing_data = data(:,problemPixels);
        fixing_P = zeros(M+1,length(problemPixels));
        parfor i=1:length(problemPixels)
            EwithMicro = [endmembers, fixing_rVec(:,i)];
            H = 2*(EwithMicro'*EwithMicro);
            c = (-2*(fixing_data(:,i)'*EwithMicro))';
            fixing_P(:,i) = quadprog(H, c, Ap, bp, [], [], [], [], [], options);
        end
        P(:,problemPixels) = fixing_P;

    end
    P(P<0) = 0;
    
end

RSS = zeros(N,1);
parfor i=1:N
    EwithMicro = [endmembers, rVec(:,i)];
    RSS(i) =(data(:,i) - EwithMicro*P(:,i))'*(data(:,i) - EwithMicro*P(:,i));
end


SSD = 0;
for i = 1:M-1
    for k= i+1:M
        SSD = SSD + sum((endmembers(:,i) - endmembers(:,k)).^2);
    end
end

Error = sum(RSS)*((1-mu)/N) + (mu/(M*(M-1)))*SSD;
RSSsum = sum(RSS)/N;

end