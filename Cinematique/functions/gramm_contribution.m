function gramm_contribution(input)
%% reshaping data
sexe     = repmat(input.sexe,[1 4]);
hauteur  = repmat(input.hauteur,[1 4]);
delta    = kron(transpose(1:4), ones(length(input.sexe),1))';
data  = vertcat(input.delta_hand, input.delta_GH, input.delta_SCAC, input.delta_RoB);
time = input.time;

% create figure
figure('units','normalized','outerposition',[0 0 1 1])
clear g

% aes
g = gramm('x', time ,'y', data, 'color', delta, 'linestyle', sexe);
% facet
g.facet_grid(hauteur,[], 'scale', 'independent','space','free');
% geom
g.stat_summary('type','sem','geom','area', 'setylim', true);
% options
g.axe_property('TickDir','out');
% titles
g.set_names()

g.draw();

end

