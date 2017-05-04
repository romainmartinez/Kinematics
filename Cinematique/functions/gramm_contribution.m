function gramm_contribution(inputData, varargin)
% reshape data
long.sex = repmat(inputData.sex,[1 4]);
long.weight = repmat(inputData.weight,[1 4]);
long.delta = kron(transpose(1:4), ones(length(inputData.sex),1))';
data.data = vertcat(inputData.deltahand, inputData.deltaGH, inputData.deltaSCAC, inputData.deltaRoB);

if nargin > 1 && contains(varargin, 'verif')
   selected = verif_gui(inputData);
else
    % gramm plot (for publication)
    % convert to string
    convert.sex = {'men','women'};
    convert.weight = {'6 kg','12 kg'};
    convert.delta = {'WR/EL','GH','SC/AC','TR/PE'};
    
    long.weight([long.weight] == 6) = 1;
    long.weight([long.weight] == 12) = 2;
    
    data.sex = convert.sex(long.sex);
    data.weight = convert.weight(long.weight);
    data.delta = convert.delta(long.delta);
    data.time = inputData.time;
    
    
    % create figure
    figure('units','normalized','outerposition',[0 0 1 1])
    clear g
    
    % aes
    g = gramm('x', data.time ,'y', data.data, 'color', data.delta, 'linestyle', data.sex);
    % facet
    g.facet_grid(data.weight, data.sexe, 'scale', 'fixed','space','free');
    % geom
    g.stat_summary('type','std','geom','area', 'setylim', true);
    % options
    g.axe_property('TickDir','out');
    % titles
    g.set_names('column','','row','','x','time (% trial)','y','contribution (% weight)','color','Contribution','linestyle','sex');
    
    
    g.draw();
    
    % export
    % g.export('file_name','test2','file_type','pdf','units','inches','width',10,'weight',6)
end

