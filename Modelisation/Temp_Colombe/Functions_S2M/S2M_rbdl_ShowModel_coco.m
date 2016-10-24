function h = S2M_rbdl_ShowModel_coco(m, Q, h)
% Fonction servant à afficher un modèle S2M_rbdl m à la position Q; h est
% un handler sur les graphiques pour updater une position

% Déclaration de tous les éléments nécessaires
nodes = S2M_rbdl('mesh', m, Q(:,1)); % Tous les nodes du meshing par segments
RT = S2M_rbdl('globalJCS', m, Q(:,1)); % Systmème d'axes par segments
T = S2M_rbdl('segmentsTags', m, Q(:,1)); % Position des marqueurs par segments
com = S2M_rbdl('com', m, Q(:,1)); % Position du CoM global
comi = S2M_rbdl('segmentCom', m, Q(:,1)); % Position des CoM par segments
C = S2M_rbdl('contacts', m, Q(:,1)); % Position des contacts
[M, wrap] = S2M_rbdl('musclePoints', m, Q(:,1)); % Position des nodes articulaires et des wrapping objects


% Déclaration des plots
if nargin < 3 || isempty(h)
    hold on
    
    % Handler sur les mesh
    for i=1:length(nodes)
        h.mesh{i} = plot3(nan, nan, nan, 'k-','linewidth',2);
    end
    
    % Handler sur les systèmes d'axes
    for i=1:size(RT,3)
        h.RT{i} = plotAxes(nan(4));
    end
    
    % Handler sur les Tags et les traits
    for i = 1:length(T)
        for j = 1:size(T{i},2)
            %h.Tags{i}.traits{j} = plot3(nan, nan, nan, 'b--');
            h.Tags{i}.points{j} = plot3(nan, nan, nan, 'bo','linewidth',1.5);
            % AJOUTER LES NOMS DES TAGS ?
        end
    end
    
    % Handler sur le CoM global
%     h.CoM = plot3(nan, nan, nan, 'k.', 'markersize', 25);
    
    % Handler sur les CoM segmentaires
%     h.CoMi = plot3(nan, nan, nan, 'k.', 'markersize', 21);

    % Handler sur les contacts
    h.contacts = plot3(nan, nan, nan, 'g.', 'markersize', 21);
    
    % Handler sur les muscles
    for i = 1:length(M)
        h.muscles{i}.traits = plot3(nan, nan, nan, 'r-','linewidth',2);
        h.muscles{i}.points = plot3(nan, nan, nan, 'r.');
    end

%     view([90, 0])
end




% Update des graphiques
% Affichage du corps
for i=1:length(nodes)
    set(h.mesh{i}, 'xdata', nodes{i}(1,:), ...
                   'ydata', nodes{i}(2,:), ...
                   'zdata', nodes{i}(3,:))
end

% Affichage des systèmes d'axe
for i=1:size(RT,3)
    plotAxes(RT(:,:,i,1),gcf,h.RT{i}, false, true);
end

% Affichage des tags 
for i = 1:length(T)
    for j = 1:size(T{i},2)
%         set(h.Tags{i}.traits{j}, 'xdata', [comi(1,i) T{i}(1,j)], ...
%                                  'ydata', [comi(2,i) T{i}(2,j)], ...
%                                  'zdata', [comi(3,i) T{i}(3,j)]);
        set(h.Tags{i}.points{j}, 'xdata', T{i}(1,j), ...
                                 'ydata', T{i}(2,j), ...
                                 'zdata', T{i}(3,j));
    end
end

% Affichage du centre de masse global
% set(h.CoM, 'xdata', com(1), 'ydata', com(2), 'zdata', com(3))

% Affichage des centre de masse segmentaire
% set(h.CoMi, 'xdata', comi(1,:), 'ydata', comi(2,:), 'zdata', comi(3,:))

% Afficher les contacts
set(h.contacts, 'xdata', C(1,:), 'ydata', C(2,:), 'zdata', C(3,:))

% Afficher les muscles
for i = 1:length(M)
    set(h.muscles{i}.traits, 'xdata', M{i}(1,:), ...
                             'ydata', M{i}(2,:), ...
                             'zdata', M{i}(3,:))
    set(h.muscles{i}.points, 'xdata', M{i}(1,:), ...
                             'ydata', M{i}(2,:), ...
                             'zdata', M{i}(3,:))
end
% 
% % Afficher les wrapping objects
% for i = 1:size(wrap,1)
%     if strcmpi(wrap{i,1}, 'cylinder')
%         [xc,yc,zc] = cylinder(wrap{i,3});
%         zc(2,:) = wrap{i,4}; % Set de la longueur
%         c1 = wrap{i,2} * [xc(1,:); yc(1,:); zc(1,:); ones(1,size(xc,2))];
%         c2 = wrap{i,2} * [xc(2,:); yc(2,:); zc(2,:); ones(1,size(xc,2))];
%         xc = [c1(1,:); c2(1,:)];
%         yc = [c1(2,:); c2(2,:)];
%         zc = [c1(3,:); c2(3,:)];
%         surf(xc,yc,zc)
%     else
%         warning('Can''t recognize the wrapping object');
%     end
%     plotAxes(wrap{i,2});
% end



end