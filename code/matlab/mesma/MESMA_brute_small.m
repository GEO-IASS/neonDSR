function [idx, A, rec, minerr]=MESMA_brute_small (x,L)
% MESMA_BRUTE_SMALL Efficient brute force approach for MESMA problems with
% a low number of endmember libraries.
% assumes that the data is vectorized: x is a (d,N) matrix, with d the 
% number of dimensions (or spectral bands) and N the number of targets. L is
% a cell array containing any number of libraries, each of size (d, libsize).
% The libsizes do not need to be the same for every library. Use reshape to
% turn 3-dim data cubes into 2-dim pixel arrays.
%
% Example:
%
% x=rand(50,1);
% L{1}=rand(50,5);   % has 5  items in library each 50 dimensions
% L{2}=rand(50,10);  % has 10 items in library each 50 dimensions
% L{3}=rand(50,15);  % has 15 items in library each 50 dimensions
% [idx, A, rec, minerr]=MESMA_brute_small (x,L)
%
% This gives you the indices into each library of the best combination, the
% abundance wrt. these library elements, the reconstructed spectrum, and 
% the error.

[d,num]=size(x);
libsCount=numel(L); % Total # of libraries
for i=1:libsCount
    NLibrary(i)=size(L{i},2); % Number of items in each library
end
minerr=inf(1,num);
idx=zeros(libsCount,num);
A=zeros(libsCount,num);
rec=zeros(d,num);

% for all the 2^p-1 subsets of library L
for setcnt=2:2^libsCount-1
    temp = de2bi(setcnt,libsCount);   % Convert decimal numbers to binary vectors
    setmask=logical(temp); % subset in logical form, called setmask

    q=sum(setmask);   % number of libraries selected for this iteration
    % We treat the q=1 case separately at the end
    if q==1
        continue;
    end
    Ni=NLibrary(setmask);  % select the libraries that have been picked
    I=zeros(1,q);  % a zero per library
    pt=1;
    M=Ni-1;
    setmask=find(setmask);   % ind = find(X) locates all nonzero elements of array X, and returns the linear indices of those elements in vector ind.
    E=zeros(d,q);     % one candidate from each library each with d dimensions
    while true
        %if q==p
        %    I
        %end
        for i=1:q
            E(:,i)=L{setmask(i)}(:,I(i)+1);   % fill-in candidate items from each library
        end
        [y,a]=plane_project2(x,E);  
        mp=find(~(sum(a<0)>0));
        for i=1:numel(mp)
            err=norm(y(:,mp(i))-x(:,mp(i)));
            if err<minerr(mp(i))
                minerr(mp(i))=err;
                idx(:,mp(i))=zeros(libsCount,1);
                idx(setmask,mp(i))=I+1;
                A(:,mp(i))=zeros(libsCount,1);
                A(setmask,mp(i))=a(:,mp(i));
                rec(:,mp(i))=y(:,mp(i));
            end
        end
            
        % generate next set indices
        pt=find(I<M);
        if isempty(pt)
            break;
        end
        pt=pt(1);
        I(pt)=I(pt)+1;
        I(1:pt-1)=0;
    end
end

% q=1 case
for i=1:libsCount
    for j=1:NLibrary(i)
        for k=1:num
            err=norm(x(:,k)-L{i}(:,j));
            if err<minerr(k)
                minerr(k)=err;
                idx(:,k)=zeros(libsCount,1);
                idx(i,k)=j;
                A(:,k)=zeros(libsCount,1);
                A(i,k)=1;
                rec(:,k)=L{i}(:,j);
            end
        end
    end
end

% sort by abundance
    [~, sorted_abundances_order] = sort(A);
    sorted_abundances = A(sorted_abundances_order);
    sorted_indexes = idx(sorted_abundances_order);
    A = sorted_abundances;
    idx = sorted_indexes;

end

% x is the input signal that we try to reconstruct, E contains candidate
% signals from each library
function [y,a]=plane_project2(x,E)
    [N,M]=size(x);
    p=size(E,2);
    a=zeros(p,M);   % abundance of each candidate to construct x
    %ct=E(:,1);
    %Ep=E(:,2:p)-ct*ones(1,p-1);
    temp1 = E(:,1) * ones(1,p-1);   % replicate the first library signal p-1 times 
    temp2 = E(:,2:p); % take the rest of the library
    Ep = temp2 - temp1;
    
    a(2:p,:)=Ep\(x-E(:,1)*ones(1,M));     % M is used: x can have more than one signal. It coud easily be (Ep+E(:,1))\x  which just ignores the initial subtract and does the same job. It just wanted to make it more complicated. KUDOS 
    a(1,:)=ones(1,M)-sum(a(2:p,:),1);  % a(1,:) is the negate of the rest of abundances
    y=E*a;
end
