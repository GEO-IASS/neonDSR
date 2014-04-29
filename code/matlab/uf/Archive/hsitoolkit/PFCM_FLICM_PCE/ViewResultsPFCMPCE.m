function ViewResultsPFCMPCE(img, P, E, U, T, figbase)

if ~exist('figbase','var') || isempty(figbase)
    figbase = 0;
end

%Flags
Endmembers = 1; % View Endmembers
ScatterFlag = 1; %View Scatter Plot
ProportionMaps = 1; %View Prop Maps
MembershipMaps = 1; %View Membership
TypicalMaps = 1; %View Typicality Maps
ProductMaps = 1; %View Product of Prop and Typicality and Membership

n_pix = size(U,2);

if n_pix > 5000
    stride = 10;
else
    stride = 1;
end

[n_row,n_col,n_band] = size(img);
X = reshape(img,n_row*n_col,n_band);
n_part = numel(E);

if(ScatterFlag)
    
    if(n_band == 2)
        
        for i = 1:length(E)
            figure(figbase+100+i);  
            hold off;
            scatter(X(1:stride:end,1), X(1:stride:end,2),...
                30, T(i,1:stride:end).*U(i,1:stride:end), 'filled');
            hold on;
            scatter(E{i}(:,1), E{i}(:,2), 100, 'k', 'filled');
            title(['Scatter Plot of Partition ', (num2str(i))]);
        end
    elseif(n_band == 3)

        for i = 1:length(E)
            figure(figbase+100+i);  
            hold off;
            scatter3(X(1:stride:end,1), X(1:stride:end,2), X(1:stride:end,3),...
                30, T(i,1:stride:end).*U(i,1:stride:end), 'filled');
            hold on;
            scatter3(E{i}(:,1), E{i}(:,2), E{i}(:,3), 100, 'k', 'filled');
            title(['Scatter Plot of Partition ', (num2str(i))]);
        end
    else

        m = mean(X);
        [t, PCAresults] = princomp(X);
        X = PCAresults(:, 1:3);
        for i = 1:length(E)
            EE = (E{i} - repmat(m, [size(E{i},1), 1]))*t;
            figure(figbase+100+i); 
            hold off;
            scatter3(X(1:stride:end,1), X(1:stride:end,2), X(1:stride:end,3),...
                30, T(i,1:stride:end).*U(i,1:stride:end),'filled');
            hold on;
            scatter3(EE(:,1), EE(:,2), EE(:,3), 100, 'k', 'filled');
            xlabel('D1');ylabel('D2');zlabel('D3');
            title(['Scatter Plot of Partition ', (num2str(i))]);
        end
    end
    
end

if(ProportionMaps)
    for i = 1:length(P)
        figure(figbase+200+i);
        for j = 1:size(P{i},2)
            subplot(ceil(size(P{i},2)/2), 2, j);  
            PP = reshape(P{i}(:,j), [n_row, n_col]);
            imagesc(PP, [0 1]); 
            title(['Proportion Map of Partition ', (num2str(i)), ' and Endmember ', (num2str(j))]);
        end
    end
end

if(MembershipMaps)
    figure(figbase+300);
    hold off;
    for i = 1:size(U,1);
        subplot(ceil(size(U,1)/2), 2, i);
        MM = reshape(U(i,:), [n_row, n_col]);
        imagesc(MM, [0 1]);
        title(['Membership Map of Partition ', (num2str(i))]);
    end
end

if(TypicalMaps)
    figure(figbase+400);
    hold off;
    for i = 1:size(T,1)
        subplot(ceil(size(T,1)/2), 2, i); 
        TT = reshape(T(i,:), [n_row, n_col]);
        imagesc(TT, [0 1]);
        title(['Typicality Map of Partition ', (num2str(i))]);
    end
end

if(ProductMaps)
    for i = 1:length(P)
        figure(figbase+500+i);
        hold off;
        TT = reshape(T(i,:), [n_row, n_col]);
        MM = reshape(U(i,:), [n_row, n_col]);
        for j = 1:size(P{i},2)
            subplot(ceil(size(P{i},2)/2), 2, j); 
            PP = reshape(P{i}(:,j), [n_row, n_col]);
            imagesc(PP.*MM.*TT, [0 1]);
            title(['Product Map of Partition ', (num2str(i)), ' and Endmember ', (num2str(j))]);
        end
    end
end

if Endmembers
    figure(figbase+600);
    hold off;
    for i = 1:n_part
        subplot(ceil(n_part/2), 2, i);
        plot(E{i}');
        ylim([min(min(E{i}(:)),0),max(max(E{i}(:)),1)]);
        title(['Endmembers of Partition ', (num2str(i))]);
    end
end

end

