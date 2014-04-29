function U=U_update_lidar(img,mask,X,P,E,U,m, LidarDist, center)

% This function updates the fuzzy membership matrix (CXN).
% Input:
%   - X: Pixel points (NXd matrix).
%   - P:  Cell of C abundance matrices. One (NXM) matrix per cluster.
%   - E:  Cell of C endmembers matrices. One (MXd) matrix per cluster.
%   - U: the fuzzy membership matrix (CXN).
%   - m: Fuzzifier.
%   - EPS: small positive constant.
% Output:
%   - U: the fuzzy membership matrix (CXN).


N=size(X,1);
C=size(U,1);
EPS=1e-40;

RSS = zeros(C,N);
for i=1:C
    Y = (X - P{i}*E{i}).^2;
    RSS(i,:) = sum(Y,2);
end
M2 = (1-U).^m;

[n_row,n_col,n_band] = size(img);
n_pix = n_row*n_col;

tmp = zeros(C,n_pix);  
tmp(:,mask(:)) = M2.*RSS; % expand with zeros for invalid pixel vals

G2 = reshape(tmp, C, n_row, n_col);
G2cell = cell(C,1);
for i=1:C
   G2cell{i} = squeeze(G2(i,:,:)); 
end

center = center(1)-1;
G = zeros(C,n_row,n_col);

ok = ~cellfun('isempty',LidarDist);

rg = -center:center;

%tic;
 for k = 1:n_col       
     for j = 1:n_row    
         if(ok(j,k)) %~isempty(LidarDist{j,k})
             for i = 1:C
                 %subI = squeeze(G2(i,j+rg, k+rg));
                 subI = G2cell{i}(j+rg,k+rg);
                 G(i,j,k) = sum(sum(subI.*LidarDist{j,k}));
             end
         end
         
     end
 end
%toc;

% to use mex version, comment out the above loop and use the line below instead
%G = u_update_lidar_loop(G2cell,ok,LidarDist,center);

G = reshape(G,[C,n_pix])';
%G(G == 0) = mean(G(G~=0));

G(~mask(:),:) = []; % remove invalid pixel vals

Dist_1=1./( ( (RSS+G'+EPS).^(1/(m-1)) ) + EPS );
%Dist_1=1./(((RSS+EPS).^(1/(m-1)))+EPS);

S = sum(Dist_1);
U = (Dist_1)./repmat(S, [C,1]);