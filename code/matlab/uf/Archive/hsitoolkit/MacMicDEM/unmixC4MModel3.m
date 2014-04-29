function [P, F, Error, RSSsum] = unmixC4MModel3(endmembers, data, dataW, mu, refAlbLookupStruct, OptParams)

fprintf('Calculating Proportions...\n');

D = size(data,1);
N = size(data,2);
M = size(endmembers, 2);
P = zeros(M+1, N);
F = zeros(M,   N);

W = lookupAlbedo3(endmembers, refAlbLookupStruct);


%update F
F = unmix_qpas_MacMic(dataW, endmembers, [], OptParams);

% H = (2*(W'*W));
% parfor i=1:N   
%     c      = (-2*(dataW(:,i)'*W))'; %%%XXX CAN THIS GO OUTSIDE THE LOOP AND BE REPLACED WITH INDEXING ONLY
%     F(:,i) = qpas(H, c, A, b, [], [], [], [], 0);
% %        [P] = unmix_qpas_correct(X, endmembers, parameters.gamma, P, parameters);
% 
% %     F(:,i) = quadprog(H, c, A, b, [], [], [], [], [], options);
% end

F(F<0) =0;

% if sum(sum(F<0)) ~= 0
%     if sum(sum(F<-1e-12)) ~= 0
%         fprintf('A negative proportion (F) was found\n');
%     end
%     F(F<0) = 0;
% end

rVec = zeros(D,N);
parfor i = 1:N
    rVec(:,i) = convertToReflectance2(W*F(:,i), refAlbLookupStruct); %%%XXX CAN THIS LOOP BE REPLACED
end

%update P
P = unmix_qpas_MacMic(data, endmembers, rVec, OptParams);
% 
% parfor i = 1:N
%     EwithMicro = [endmembers, rVec(:,i)];
%     H          = 2*(EwithMicro'*EwithMicro);
%     c          = (-2*(data(:,i)'*EwithMicro))';
%     P(:,i)     = qpas(H, c, Ap, bp, [], [], zeros([M+1,1]), [], 0);
% end

if sum(sum(P<0)) ~= 0
    if sum(sum(P<-1e-12)) ~= 0
%         fprintf('A non-zero proportion (P) was found\n');
%         disp(strcat('Number of Problems: ',num2str(sum(sum(P<-1e-12)))));
        problemPixels=find(sum(P<-1e-12 | P>(1+1e-12))>0);
        
        fixing_rVec = rVec(:,problemPixels);
        fixing_data = data(:,problemPixels);
        fixing_P    = zeros(M+1,length(problemPixels));
        parfor i=1:length(problemPixels)
            EwithMicro    = [endmembers, fixing_rVec(:,i)];
            H             = 2*(EwithMicro'*EwithMicro);
            c             = (-2*(fixing_data(:,i)'*EwithMicro))';
            fixing_P(:,i) = quadprog(H, c, Ap, bp, [], [], [], [], [], options);
        end
        P(:,problemPixels) = fixing_P;
    end
    P(P<0) = 0;
    
end

RSS = zeros(N,1); %%%DO WITHOUT A LOOK
parfor i=1:N
    EwithMicro = [endmembers, rVec(:,i)];
    Diff       = data(:,i) - EwithMicro*P(:,i);
    RSS(i)     = Diff'*Diff;
end


SSD = 0; %CAN COMPUTE USING var?
for i = 1:M-1
    for k= i+1:M
        SSD = SSD + sum((endmembers(:,i) - endmembers(:,k)).^2);
    end
end

Error = sum(RSS)*((1-mu)/N) + (mu/(M*(M-1)))*SSD;
RSSsum = sum(RSS)/N;

fprintf('Done calculating proportions...\n');
end