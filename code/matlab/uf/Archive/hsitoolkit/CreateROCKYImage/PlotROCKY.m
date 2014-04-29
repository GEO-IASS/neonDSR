function PlotROCKY(rocky_output,title_str)

rocky = rocky_output.ROCKY;

pds = vertcat(rocky{:,2});
fars = vertcat(rocky{:,3});

plot(fars,pds);
xlabel('FAR (FA / m^2)');
ylabel(sprintf('PD (%d targets)',numel(rocky_output.filteredTruth.Targets_Type)));
ylim([0 1]);
grid on;

tstr{1} = title_str;

if isempty(rocky_output.targetFilter)
    tstr{2} = 'All Targets';
else

    for i=1:numel(rocky_output.targetFilter)
        el = rocky_output.targetFilter{i};
        if isempty(el{1})
            name = 'All Types';
        else
            name = el{1};
        end
        if isempty(el{2})
            sizes = 'All Sizes';
        else
            sizes = ['Sizes ' num2str(el{2})];
        end
        if isempty(el{3})
            conf = 'All Truth Confs';
        else
            conf = ['Truth Conf ' num2str(el{3})];
        end
        if isempty(el{4})
            occ = 'All Occl. Types';
        else
            occ = ['Occ ' num2str(el{4})];
        end
        
        tstr{i+1} = [name ', ' sizes ', ' conf ', ' occ];
    end
    
end
title(tstr);

end