function PlotBullwinkleRoc(bw_out,title_str,varargin)

p = inputParser();
p.addParamValue('scale','lin',@(x)any(strcmpi(x,{'lin','log'})));
p.addParamValue('farbars',false,@(x)isscalar(x));
p.addParamValue('xlim',[],@(x)isnumeric(x)&&numel(x)==2);
p.addParamValue('ylim',[],@(x)isnumeric(x)&&numel(x)==2);
p.addParamValue('names',[],@(x)ischar(x)||iscellstr(x));
p.parse(varargin{:});
args = p.Results;


clf;

if ~iscell(bw_out)
    bw_out = {bw_out};
end
if isempty(args.names)
    for i=1:numel(bw_out)
        names{i} = bw_out{i}.name;
    end
else
    names = args.names;
end

colors = {'r','m','b','c','g','y','k'};
specs = {'-','--','-.',':'};
n_color = numel(colors);
curr_color = 1;
curr_spec = 1;

if args.farbars    
    for i=1:numel(bw_out)
        bw = bw_out{i}.Bullwinkle;
        
        pds = vertcat(bw{:,2});
        fars = vertcat(bw{:,3});
        
        max_far = fars(end);
        n_fa = bw_out{i}.n_fa;
        x_array = min(n_fa*fars/max_far,n_fa);
        [~,pci] = binofit(x_array,n_fa*ones(numel(x_array),1));
        
        bar_x = max_far * ([pci(:,1); pci(end:-1:1,2)]);
        bar_y = [pds; pds(end:-1:1)];
        
        if strcmpi(args.scale,'lin')
            nolegend(fill(bar_x,bar_y,colors{curr_color},'FaceAlpha',.05,'EdgeColor',colors{curr_color},...
               'LineStyle','--', 'HitTest','on', 'tag', 'transient')); %facealpha was 0.1 edgecolor was 'none'
            %nolegend(plot(bar_x,bar_y,colors{curr_color},'LineStyle','--'));
        else
            nolegend(fill(bar_x,bar_y,colors{curr_color},'FaceAlpha',0.1,'EdgeColor',colors{curr_color},...
                'LineStyle','--', 'HitTest','on', 'tag', 'transient'));
        end

        hold on;
        
        curr_color = curr_color+1;
        if curr_color > n_color
            curr_color = 1;
            curr_spec = curr_spec + 1;
        end
    end
end

curr_color = 1;
curr_spec = 1;

for i=1:numel(bw_out)
    bw = bw_out{i}.Bullwinkle;
    
    pds = vertcat(bw{:,2});
    fars = vertcat(bw{:,3});
    
    if strcmpi(args.scale,'log')
        semilogx(fars,pds,[colors{curr_color} specs{curr_spec}],'LineWidth',2);
    else
        plot(fars,pds,[colors{curr_color} specs{curr_spec}],'LineWidth',2);
    end
    hold on;
    
    curr_color = curr_color+1;
    if curr_color > n_color
        curr_color = 1;
        curr_spec = curr_spec + 1;
    end
end
legend(names,'Location','Best');


bw1 = bw_out{1};
n_tgt = numel(bw1.filteredTruth.Targets_Type);
ylabel({'PD',sprintf('(%d targets, 1 Det = %.3f)',n_tgt,1/n_tgt)});
    
xlabel({'FAR (FA / m^2)',sprintf('(%d m^2, 1 FA = %.3g)',round(bw1.fa_area),1/bw1.fa_area)});

if ~isempty(args.xlim)
    xlim(args.xlim);
end
if ~isempty(args.ylim)
    ylim(args.ylim);
else
    ylim([-0.01 1.01]);
end
grid on;

tstr{1} = title_str;

if isempty(bw1.targetFilter)
    tstr{end+1} = 'All Targets';
else

    for i=1:numel(bw1.targetFilter)
        el = bw1.targetFilter{i};
        if isempty(el{1})
            name = 'All Types';
        elseif iscell(el{1})
            name = '\{';
            for j=1:(numel(el{1})-1)
                name = [name el{1}{j} ','];
            end
            name = [name el{1}{end} '\}'];
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
        
        tstr{end+1} = [name ', ' sizes ', ' conf ', ' occ];
    end
    
end

bw_params = bw1.Bullwinkle_params;
if bw_params.ignore_clutter
    ic = ', Ignoring Clutter';
else
    ic = '';
end
tstr{end+1} = sprintf('Halo: %dm %s',bw_params.Halo,ic);

title(tstr);

end

function thing = nolegend(thing)
  set(get(get(thing,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end
