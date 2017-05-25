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
        %         method = 'drop'; % interaction or drop
        %         if contains(method, 'interaction')
        %             zone.WREL = 63:69;
        %             zone.GH = 55:72;
        %             zone.SCAC = 60:100;
        %             zone.TRPE = 60:100;
        %         elseif contains(method, 'drop')
        %             zone.WREL = 60:100;
        %             zone.GH = 60:100;
        %             zone.SCAC = 60:100;
        %             zone.TRPE = 60:100;
        %         else
        %             error('Choose valid method (interaction or drop)')
        %         end
        zone = 60:100;
        df.scalar = mean(df.data(:,zone), 2)';
        % normalization with box mass/subject mass
        df.normalizedweight = repmat(input.weight ./ input.subjweight,[1 4]);
        
        
        figure('units','normalized','outerposition',[0 0 1 1])
        clear g
        g=gramm('x',df.normalizedweight,'y',df.scalar,'color',df.sex);
        g.facet_grid([], df.delta, 'scale', 'fixed','space','free');
        g.geom_point('alpha', 0.5);
        g.set_point_options('base_size', 3)
        g.stat_glm('disp_fit', true, 'geom', 'lines');
        g.draw();
        
%         subset = df.delta == 1 & df.sex == 2;
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
    
    g = gramm('x', df.time ,'y', df.data, 'color', df.delta);
    g.stat_summary('type','std','geom','lines', 'setylim', true);
    g.axe_property('TickDir','out');
    g.set_names('column','','row','','x','time (% trial)','y','contribution (% weight)','color','Contribution','linestyle','sex');
    g.draw();
         
    % export
    % g.export('file_name','test2','file_type','pdf','units','inches','width',10,'height',6)
end