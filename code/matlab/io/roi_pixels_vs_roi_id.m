% distribution of roi pixels vs roi id

uniq_rois = unique(rois);

pixel_per_roi = zeros(numel(uniq_rois),1);
class_per_roi = cell(numel(uniq_rois),1);
for i=1:numel(uniq_rois)
    pixel_per_roi(i) = sum(rois==i);
    t = find(rois==uniq_rois(i));
    if i == 50
        disp('a');
    end
    idx = t(1);
    class_per_roi(i) = species(idx);
end
disp('done')


unique_rois = unique(rois);
unique_rois_species =  cell(numel(unique_rois),1);
for i = 1:numel(unique_rois)
    roiIdx = rois == unique_rois(i);
    rois_specie = species(roiIdx);
    unique_rois_species(i) = rois_specie(1);
end

figure
uniq_species = unique(species);
marker = ['+' 'o' 'x' '*' 'd' '^'];
colors = ['r' 'b' 'k' 'g' 'm' 'c'];
colors = ['k' 'k' 'k' 'k' 'r' 'r'];


titles = cell(numel(uniq_species), 1);


for i=1:numel(uniq_species)
    x = find(strcmp(unique_rois_species, uniq_species(i)));
    
    idx = strcmp(unique_rois_species, uniq_species(i));
    y = pixel_per_roi(idx);
    
    if strcmp(uniq_species(i), 'pine')
        titles(i) = cellstr('Pinus (other)');
    elseif strcmp(uniq_species(i), 'oak_hemisphaerica')
        titles(i) = cellstr('Quercus Hemisphaerica');
    elseif strcmp(uniq_species(i), 'oak')
        titles(i) = cellstr('Quercus (other)');
    elseif strcmp(uniq_species(i), 'pine_longleaf')
        titles(i) = cellstr('Pinus Palustris');
    elseif strcmp(uniq_species(i), 'oak_turkey')
        titles(i) = cellstr('Quercus Laevis');
    elseif strcmp(uniq_species(i), 'oak_live')
        titles(i) =cellstr('Quercus Geminata');
    end
    
    
    
    %  rois_with_same_specie = uniq_rois(unique_rois_species)
    hold on
    scatter(x, y, marker(i), colors(i));
end
legend(titles);
xlabel('ROI Id');
ylabel('# of Pixels');