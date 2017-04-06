function [ output_args ] = gramm_boite(input)
idx = find(input.poids == 1);
% convert to string
convert.sexe = {'men','women'};
convert.hauteur = {'hips-shoulder','hips-eyes','hips-shoulder','shoulders-eyes','hips-eyes','shoulders-eyes'};
convert.delta = {'WR/EL','GH','SC/AC','TR/PE'};
convert.sens  = {'upward', 'downward'};

data.sexe = convert.sexe(input.sexe);
data.hauteur = convert.hauteur(input.hauteur);
data.sens(input.hauteur == 1 | input.hauteur == 2 | input.hauteur == 4) = convert.sens(1);
data.sens(input.hauteur == 3 | input.hauteur == 5 | input.hauteur == 6) = convert.sens(2);
data.time = input.time;
data.data = input.boite;


% create figure
figure('units','normalized','outerposition',[0 0 1 1])
clear g

% aes
g = gramm('x', data.time ,'y', data.data);
% facet
g.facet_grid(data.hauteur,data.sens, 'scale', 'fixed','space','free');
% geom
g.stat_summary('type','std','geom','line', 'setylim', true);
% options
g.axe_property('TickDir','out');
% titles
g.set_names('column','','row','','x','time (% trial)','y','contribution (% height)','color','Contribution','linestyle','sex');


g.draw();

% export
% g.export('file_name','test2','file_type','pdf','units','inches','width',10,'height',6)

