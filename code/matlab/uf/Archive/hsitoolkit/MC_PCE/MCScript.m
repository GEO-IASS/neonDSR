function [E, C, P] = MC_PCE(HylidImage, Parameters);

Data = double(HylidImage.Data);
%% Partitioning
[~,~,PFCMPCE_U,~] = PFCMPCE(Data,Parameters.PFCMPCE_Params);

[~, Partition_Index] = max(PFCMPCE_U);
Pixels = reshapeImage(Data);
for i=1:size(PFCMPCE_U,1)
    Partitioned_Data{i} = Pixels(:,Partition_Index==i);
end

%% SPICE
for i=1:size(Partitioned_Data,2)
    Endmembers{i} = [];
    for j=1:Parameters.SPICE_Iterations
       [endmem, ~]=SPICE(double(Partitioned_Data{i}),Parameters.SPICE_Params);
       Endmembers{i} = [Endmembers{i} endmem];
    end
end


%% Clustering




