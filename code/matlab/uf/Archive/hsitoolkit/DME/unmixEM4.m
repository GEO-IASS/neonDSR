function [P, F, t, Error, RSSerror] = unmixEM4(endmembers, data, dataW, mu, refAlbLookupStruct)
D = size(data,1);
N = size(data,2);
M = size(endmembers, 2);
P = zeros(M, N);
F = zeros(M, N);

options = optimset('Display', 'off', 'LargeScale', 'off');

%set up constraint matrices
A = vertcat(vertcat(-1*eye(M), ones([1, M]), -1*ones([1, M])));
b = vertcat(vertcat(zeros([M, 1]), 1), -1);

At = vertcat(vertcat(-1*eye(2), ones([1, 2]), -1*ones([1, 2])));
bt = vertcat(vertcat(zeros([2, 1]), 1), -1);

%update P
H = 2*(endmembers'*endmembers);
parfor i = 1:N
    
    c = (-2*(data(:,i)'*endmembers))';
    P(:,i) = quadprog(H, c, A, b, [], [], [], [], [], options);
end

if sum(sum(P<0)) ~= 0
    if sum(sum(P<-1e-12)) ~= 0
        fprintf('A non-zero proportion (P) was found\n');
    end
    P(P<0) = 0;
end

%update F
W = zeros(D,M);
parfor i=1:M
    W(:,i) =  lookupAlbedo2(endmembers(:,i), refAlbLookupStruct);
end

H = (2*(W'*W));
parfor i=1:N
    c = (-2*(dataW(:,i)'*W))';
    F(:,i) = quadprog(H, c, A, b, [], [], [], [], [], options);
end

if sum(sum(F<0)) ~= 0
    if sum(sum(F<-1e-12)) ~= 0
        fprintf('A non-zero proportion (F) was found\n');
    end
    F(F<0) = 0;
end

%update t
RSSmic = zeros(N,1);
RSSmac = zeros(N,1);
parfor i=1:N
    
     RSSmic(i) = sum((data(:,i) - convertToReflectance2(W*F(:,i), refAlbLookupStruct)).^2);
    RSSmac(i) = sum((data(:,i) - endmembers*P(:,i)).^2);
end

t = zeros(2,N);
parfor i=1:N
    c = [RSSmac(i), RSSmic(i)]';
    t(:,i) = linprog(c, At, bt, [], [], [], [], [], options);
end
%  t(2,:) = ones(1,N);
%estimate error
RSS = [RSSmac, RSSmic].*t';

sumRSS = sum(sum(RSS));
SSD = 0;
for i = 1:M-1
    for k= i+1:M
        SSD = SSD + sum((endmembers(:,i) - endmembers(:,k)).^2);
    end
end

Error = sumRSS*((1-mu)/N) + (mu/(M*(M-1)))*SSD;
RSSerror = sumRSS/N;
end