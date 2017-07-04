function selected = gramm_contribution(input, varargin)

if nargin > 1 && contains(varargin, 'verif')
    selected = verif_gui(input);
else
    % gramm plot (for publication)
    % reshape data
    df.sex = repmat(input.sex,[1 4]);
    df.weight = repmat(input.weight,[1 4]);
    df.delta = kron(transpose(1:4), ones(length(input.sex),1))';
    df.data = vertcat(input.deltahand, input.deltaGH, input.deltaSCAC, input.deltaRoB);
    df.time = input.time;
    
    
    
    if nargin > 1 && contains(varargin, 'corr')
        zone = 60:100; % zone of scalar calculation
        df.scalar = mean(df.data(:,zone), 2)';
        % normalization with box mass/subject mass
        df.normalizedweight = repmat(input.weight ./ input.subjweight,[1 4]);
        
        % delete SC/AC & TR/PE
        id = df.delta == 3 | df.delta == 4;
        
        figure('units','normalized','outerposition',[0 0 1 1])
        clear g
        g=gramm('x',df.normalizedweight(~id),'y',df.scalar(~id),'color',df.sex(~id));
        g.facet_grid(df.delta(~id), df.weight(~id), 'scale', 'fixed', 'space', 'free');
        g.geom_point('alpha', 0.5);
        g.stat_glm('disp_fit', true, 'geom', 'lines');
%         g.set_color_options('map', [0 0.6 1 ; 0.8 0 0.2])
        g.draw();
  
%         df.normalizedweight = df.normalizedweight(~id)
%         df.scalar = df.scalar(~id)
%         subset = df.delta(~id) == 2 & df.sex(~id) == 2 & df.weight(~id) == 12;
%         [Rho, pvalue] = corr(df.normalizedweight(subset)', df.scalar(subset)', 'type', 'Pearson')   
    end
    
    % create figure
    figure('units','normalized','outerposition',[0 0 1 1])
    clear g
    
    g = gramm('x',df.time,'y',df.data, 'color',df.delta,'linestyle',df.sex);
    g.facet_grid(df.weight, df.sex,'scale','fixed','space','free');
    g.stat_summary('type','std','geom','lines', 'setylim', true);
    g.axe_property('TickDir','out');
    g.set_names('column','','row','','x','time (% trial)','y','contribution (% weight)','color','Contribution','linestyle','sex');
    g.draw();
    
%     g = gramm('x', df.time ,'y', df.data, 'color', df.delta);
%     g.stat_summary('type','std','geom','lines', 'setylim', true);
%     g.axe_property('TickDir','out');
%     g.set_names('column','','row','','x','time (% trial)','y','contribution (% weight)','color','Contribution','linestyle','sex');
%     g.draw();
         
    % export
    % g.export('file_name','test2','file_type','pdf','units','inches','width',10,'height',6)
end