function gramm_contribution(input)
plot_data = input;
plot_data.sexe     = repmat(plot_data.sexe,[1 4]);
plot_data.hauteur  = repmat(plot_data.hauteur,[1 4]);
plot_data.poids    = repmat(plot_data.poids,[1 4]);
plot_data.delta    = kron(transpose(1:4), ones(length(plot_data.condition),1));
plot_data.data  = vertcat(plot_data.delta_hand, plot_data.delta_GH, plot_data.delta_SCAC, plot_data.delta_RoB);

% create figure
figure('units','normalized','outerposition',[0 0 1 1])
clear g


g(1,1) = gramm('x', plot_data.time ,'y', plot_data.data, 'color', plot_data.sexe, 'subset', plot_data.hauteur == 1 & SPM.delta == 1);
g(1,1).stat_summary('type','std');
g.draw();


end

