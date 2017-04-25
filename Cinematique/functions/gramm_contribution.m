function gramm_contribution(input)
%% reshaping data
long.sexe     = repmat(input.sexe,[1 4]);
long.hauteur  = repmat(input.hauteur,[1 4]);
long.delta    = kron(transpose(1:4), ones(length(input.sexe),1))';
data.data  = vertcat(input.delta_hand, input.delta_GH,...
    input.delta_SCAC, input.delta_RoB);

% convert to string
convert.sexe = {'men','women'};
convert.hauteur = {'hips-shoulder','hips-eyes','hips-shoulder','shoulders-eyes','hips-eyes','shoulders-eyes'};
convert.delta = {'WR/EL','GH','SC/AC','TR/PE'};
convert.sens  = {'upward', 'downward'};

data.sexe    = convert.sexe(long.sexe);
data.hauteur = convert.hauteur(long.hauteur);
data.delta   = convert.delta(long.delta);
data.sens(long.hauteur == 1 | long.hauteur == 2 | long.hauteur == 4) = convert.sens(1);
data.sens(long.hauteur == 3 | long.hauteur == 5 | long.hauteur == 6) = convert.sens(2);
data.time    = input.time;


% create figure
figure('units','normalized','outerposition',[0 0 1 1])
clear g

% aes
g = gramm('x', data.time ,'y', data.data, 'color', data.delta, 'linestyle', data.sexe);
% facet
g.facet_grid(data.hauteur,data.sens, 'scale', 'fixed','space','free');
% geom
g.stat_summary('type','std','geom','area', 'setylim', true);
% options
g.axe_property('TickDir','out');
% titles
g.set_names('column','','row','','x','time (% trial)','y','contribution (% height)','color','Contribution','linestyle','sex');


g.draw();

% export
% g.export('file_name','test2','file_type','pdf','units','inches','width',10,'height',6)
end