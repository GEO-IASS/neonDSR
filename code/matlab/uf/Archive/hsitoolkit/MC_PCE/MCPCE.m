function [E, C, P] = MCPCE(HylidImage, Parameters)

%[E, C, P] = MCPCE(HylidImage, Parameters)

Data = double(HylidImage.Data);
%% Partitioning
disp('Started PFCMPCE');
[~,~,PFCMPCE_U,~] = PFCMPCE(Data,Parameters.PFCMPCE_Params);
[~, Partition_Index] = max(PFCMPCE_U);
Pixels = reshapeImage(Data);
for i=1:Parameters.PFCMPCE_Params.C
    Partitioned_Data{i} = Pixels(:,Partition_Index==i);
end
disp('Completed PFCMPCE');

%% SPICE
disp('Started SPICE');
for i=1:Parameters.PFCMPCE_Params.C
    Endmembers{i} = [];
    for j= 1:Parameters.SPICE_Iterations
       [endmem, ~]=SPICE(double(Partitioned_Data{i}),Parameters.SPICE_Params);
       Endmembers{i} = [Endmembers{i} endmem];
    end
end
disp('Completed SPICE');


%% Clustering
disp('Started Clustering');
for i = 1:Parameters.PFCMPCE_Params.C
    [E{i},CA_U{i},~]=CA(Endmembers{i}',Parameters.CA_Params);
end
disp('Completed Clustering');
%% Unmix
disp('Started Unmixing');

for i=1:Parameters.PFCMPCE_Params.C
    [~, ClusterIndex] = max(CA_U{i},[],2);
    k=1;
    for j=1:size(E{i},1)
        if(sum(ClusterIndex==j)>0)
            Clusters{i}{k} = Endmembers{i}(:,ClusterIndex==j);
            NCM_E(k,:) = E{i}(j,:);
            C{i}{k} = cov(Clusters{1,i}{k}');
            NCM_C(k,:) = diag(C{1,i}{k});
            k=k+1;
        end
    end
    E{i} = NCM_E;
    NCM_P = ncmProportionEstimate(Partitioned_Data{i}',NCM_E,NCM_C);
    P{i} = NaN(size(Pixels,2),size(NCM_P,2));
    P{i}(Partition_Index==i,:) = NCM_P;
    figure(); % Display Proportion Maps
    for j=1:size(NCM_E,1)
        subplot(ceil(sqrt(size(NCM_E,1))),ceil(size(NCM_E,1)/ceil(sqrt(size(NCM_E,1)))),j);
        h = imagesc(reshape(P{i}(:,j),size(Data,1),size(Data,2)));
        set(h,'alphadata',~isnan(reshape(P{i}(:,j),size(Data,1),size(Data,2))));
    end
    figure(); % Display Endmembers
    for j=1:size(NCM_E,1)
        subplot(ceil(sqrt(size(NCM_E,1))),ceil(size(NCM_E,1)/ceil(sqrt(size(NCM_E,1)))),j);
        plot(HylidImage.info.wavelength, Clusters{1,i}{j},'b');
        hold on;
        plot(HylidImage.info.wavelength, E{i}(j,:),'--g','LineWidth',3);
        hold off;
    end
    clearvars NCM_E NCM_C
end

disp('Completed Unmixing');









