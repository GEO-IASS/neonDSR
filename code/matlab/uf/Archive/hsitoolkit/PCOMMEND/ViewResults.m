function ViewResults(Image, P, E, U);
%function ViewResults(Image, P, E, U);

%Flags
ScatterFlag = 1; %View Scatter Plot
subsampleValue = 10;
ProportionMaps = 0; %View Prop Maps
MembershipMaps = 1; %View Membership
ProductMaps = 1; %View Product of Prop and Membership

if(ScatterFlag)
    if(size(Image,3) == 2)
        [IList] = reshapeImage(Image)';
        for i = 1:length(E)
            figure(100+i);  
            hold off;
            scatter(IList(1:subsampleValue:end,1), IList(1:subsampleValue:end,2), 30, U(i,1:subsampleValue:end), 'filled');
            hold on;
            scatter(E{i}(:,1), E{i}(:,2), 100, 'k', 'filled'); title(['Scatter Plot of Partition ', (num2str(i))]);
        end
    elseif(size(Image,3) == 3)
        [IList] = reshapeImage(Image)';
        for i = 1:length(E)
            figure(100+i);  
            hold off;
            scatter3(IList(1:subsampleValue:end,1), IList(1:subsampleValue:end,2), IList(1:subsampleValue:end,3), 30, U(i,1:subsampleValue:end), 'filled');
            hold on;
            scatter3(E{i}(:,1), E{i}(:,2), E{i}(:,3), 100, 'k', 'filled'); title(['Scatter Plot of Partition ', (num2str(i))]);
        end
            figure(600);  
            hold off;
            [zz, ll] = max(U(:,1:subsampleValue:end), [], 1);
            scatter3(IList(1:subsampleValue:end,1), IList(1:subsampleValue:end,2), IList(1:subsampleValue:end,3), 30, zz, 'filled');
    else
        [IList] = reshapeImage(Image)';
        m = mean(IList);
        [t, PCAresults] = princomp(IList);
        IList = PCAresults(:, 1:3);
        for i = 1:length(E)
            EE = (E{i} - repmat(m, [size(E{i},1), 1]))*t;
            figure(100+i); 
            hold off;
            scatter3(IList(1:subsampleValue:end,1), IList(1:subsampleValue:end,2), IList(1:subsampleValue:end,3), 30, U(i,1:subsampleValue:end),'filled');
            hold on;
            scatter3(EE(:,1), EE(:,2), EE(:,3), 100, 'k', 'filled'); title(['Scatter Plot of Partition ', (num2str(i))]);
        end
    end
    
end

if(ProportionMaps)
    for i = 1:length(P)
        figure(200+i);
        for j = 1:size(P{i},2)
            subplot(ceil(size(P{i},2)/2), 2, j);  
            PP = reshape(P{i}(:,j), [size(Image,1), size(Image,2)]);
            imagesc(PP, [0 1]); title(['Proportion Map of Partition ', (num2str(i)), ' and Endmember ', (num2str(j))]);
        end
    end
end

if(MembershipMaps)
    figure(300); hold off;
    for i = 1:size(U,1);
        subplot(ceil(size(U,1)/2), 2, i);
        MM = reshape(U(i,:), [size(Image,1), size(Image,2)]);
        imagesc(MM, [0 1]);  title(['Membership Map of Partition ', (num2str(i))]);
    end
end


if(ProductMaps)
    for i = 1:length(P)
        figure(500+i); hold off;
        MM = reshape(U(i,:), [size(Image,1), size(Image,2)]);
        for j = 1:size(P{i},2)
            subplot(ceil(size(P{i},2)/2), 2, j);
            PP = reshape(P{i}(:,j), [size(Image,1), size(Image,2)]);
            imagesc(PP.*MM, [0 1]); title(['Product Map of Partition ', (num2str(i)), ' and Endmember ', (num2str(j))]);
        end
    end
end


end


function [IList] = reshapeImage(Image)
    IList = reshape(shiftdim(Image(:,:,:),2),size(Image,3),size(Image,1)*size(Image,2));
end

