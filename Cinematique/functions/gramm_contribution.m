function gramm_contribution(input)
idx = find(input.poids == 1);
%% reshaping data
long.sexe     = repmat(input.sexe(idx),[1 4]);
long.hauteur  = repmat(input.hauteur(idx),[1 4]);
long.delta    = kron(transpose(1:4), ones(length(input.sexe(idx)),1))';
data.data  = vertcat(input.delta_hand(idx,:), input.delta_GH(idx,:),...
    input.delta_SCAC(idx,:), input.delta_RoB(idx,:));

% convert to string
convert.sexe = {'men','women'};
convert.hauteur = {'hips-shoulder','hips-eyes','hips-shoulder','shoulders-eyes','hips-eyes','shoulders-eyes'};
convert.delta = {'hand + EL','GH','SCAC','RoB'};
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
g.facet_grid(data.hauteur,data.sens, 'scale', 'free','space','fixed');
% geom
g.stat_summary('type','std','geom','area', 'setylim', true);
% options
g.axe_property('TickDir','out');
% titles
g.set_names('column','','row','','x','time (% trial)','y','contribution (% height)','color','Contribution','linestyle','sex');

g.draw();
end

