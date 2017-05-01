function gramm_contribution(input)
%% reshaping data
long.sex = repmat(input.sex,[1 4]);
long.weight = repmat(input.weight,[1 4]);
long.delta = kron(transpose(1:4), ones(length(input.sex),1))';
data.data = vertcat(input.deltahand, input.deltaGH, input.deltaSCAC, input.deltaRoB);

% convert to string
convert.sex = {'men','women'};
convert.weight = {'6 kg','12 kg'};
convert.delta = {'WR/EL','GH','SC/AC','TR/PE'};


long.weight([long.weight] == 6) = 1;
long.weight([long.weight] == 12) = 2;

data.sex    = convert.sex(long.sex);
data.weight = convert.weight(long.weight);
data.delta   = convert.delta(long.delta);
data.time    = input.time;

% create figure
figure('units','normalized','outerposition',[0 0 1 1])
clear g

% aes
g = gramm('x', data.time ,'y', data.data, 'color', data.delta, 'linestyle', data.sex);
% facet
g.facet_grid(data.weight, data.sex, 'scale', 'fixed','space','free');
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