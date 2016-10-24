% Cette fonction démarre un petit programme qui permet de bouger à souhait
% un modèle s2m


classdef S2M_rbdl_reader_coco < handle
    methods
        % Constructor
        function h = S2M_rbdl_reader_coco(s2mpath)

            % Trouver si une instance existe d�j�
            hfigPrinc = findobj('tag', 'figPrinc');
            a = get(hfigPrinc, 'userdata');
            
            if ~isempty(a)
                S2M_rbdl_reader.closeReader(a.figPrinc)
            end
            
            % Loading du modèle 
            h.model = S2M_rbdl('new', s2mpath);
            h.Q = zeros(S2M_rbdl('ndof', h.model),1);

            % Création des figures
            h.figPrinc = figure('name', 'Modèle s2m', ... % Figure principale d'affichage
                          'units', 'normalized',...
                          'position', [0.5, 0.1, 0.5, 0.8], ...
                          'tag', 'figPrinc', ...
                          'CloseRequestFcn', @S2M_rbdl_reader_coco.closeReader); 
            h.showModel = S2M_rbdl_ShowModel_coco(h.model, h.Q); % Pointeur sur le modèle en position neutre

            axis equal
            axis tight



            % Création de la figure pour les sliders
            nameDof = S2M_rbdl('nameDof', h.model);
            sizey = 40*length(nameDof)+100;

                % Déterminer la position de la fenetre principale pour placer celle-ci
                set(h.figPrinc, 'units', 'pixels');
                fp = get(h.figPrinc, 'position');
                set(h.figPrinc, 'units', 'normalized');

            h.sliders = figure('name', 'sliders', ...
                          'units', 'pixels', ...
                          'position', [fp(1)-670-9 (fp(2)+fp(2)+fp(4))/2-sizey/2 670 sizey], ...
                          'CloseRequestFcn', [], ...
                          'menubar', 'none');


            % Entete
            uicontrol(h.sliders, ...
                'style', 'text', ...
                'string', 'DoF name', ...
                'HorizontalAlignment', 'center', ... 
                'fontsize', 14, ...
                'position', [20 sizey-50 200 25])
            uicontrol(h.sliders, ...
                'style', 'text', ...
                'string', 'Sliders', ...
                'HorizontalAlignment', 'center', ... 
                'fontsize', 14, ...
                'position', [250 sizey-50 225 25])
           uicontrol(h.sliders, ...
                'style', 'text', ...
                'string', 'Bornes', ...
                'HorizontalAlignment', 'center', ... 
                'fontsize', 14, ...
                'position', [490 sizey-50 100 25])

            uicontrol(h.sliders, ...
                'style', 'text', ...
                'string', 'Value', ...
                'HorizontalAlignment', 'center', ... 
                'fontsize', 14, ...
                'position', [600 sizey-50 50 25])


            for i=1:length(nameDof)
                % Affichage du nom de DoF
                uicontrol(h.sliders, ...
                    'style', 'text', ...
                    'string', [nameDof{i} ':'], ...
                    'HorizontalAlignment', 'right', ... 
                    'fontsize', 14, ...
                    'position', [20 sizey-40*i-70 200 25])

                % Affichage des sliders associés
                uicontrol(h.sliders, ...
                    'style', 'slider', ...
                    'min', -pi, ...
                    'max', pi, ...
                    'value', 0, ...
                    'SliderStep', [.01 .1], ...
                    'string', [nameDof{i} ':'], ...
                    'HorizontalAlignment', 'right', ... 
                    'fontsize', 14, ...
                    'tag', sprintf('Slider_%d', i), ...
                    'position', [250 sizey-40*i-70 225 25], ....
                    'callback', @S2M_rbdl_reader_coco.changePositionFromSlider);

                % Affichage des bornes min
                uicontrol(h.sliders, ...
                    'style', 'edit', ...
                    'string', '-3.1', ...
                    'HorizontalAlignment', 'center', ... 
                    'fontsize', 12, ...
                    'position', [490 sizey-40*i-70 50 25], ...
                    'tag', sprintf('BorneMin_%d', i), ...
                    'enable', 'off')

                % Affichage des bornes max
                uicontrol(h.sliders, ...
                    'style', 'edit', ...
                    'string', '3.1', ...
                    'HorizontalAlignment', 'center', ... 
                    'fontsize', 12, ...
                    'position', [540 sizey-40*i-70 50 25], ...
                    'tag', sprintf('BorneMax_%d', i), ...
                    'enable', 'off')

                % Affichage de la valeur actuelle
                uicontrol(h.sliders, ...
                    'style', 'edit', ...
                    'string', '0', ...
                    'HorizontalAlignment', 'center', ... 
                    'fontsize', 12, ...
                    'tag', sprintf('Value_%d', i), ...
                    'position', [600 sizey-40*i-70 50 25], ....
                    'callback', @S2M_rbdl_reader_coco.changePositionFromValue)
            end


            figure(h.figPrinc);
            view([60 20]);

            % Enregistrer les handlers
            set(h.figPrinc, 'UserData', h);
            S2M_rbdl_reader_coco.updateAll;
        end
    end
    
    methods (Static, Access = public)
        function changePositionFromSlider(a,~)

            % Trouver quel DoF a bougé
            tag = get(a, 'tag');
            idx = strfind(tag, '_');
            ntag = str2double(tag(idx+1:end));

            % Update de Q
            S2M_rbdl_reader_coco.modifyQ(ntag, get(a, 'value'));

        end
        function changePositionFromValue(a,~)

            % Trouver quel DoF a bougé
            tag = get(a, 'tag');
            idx = strfind(tag, '_');
            ntag = str2double(tag(idx+1:end));

            % Update de Q
            val = str2double(get(a, 'string'));
            valMin = str2double(get(findobj('tag', sprintf('BorneMin_%d', idx)), 'string'));
            valMax = str2double(get(findobj('tag', sprintf('BorneMax_%d', idx)), 'string'));

            if val < valMin
                val = valMin;
            elseif val > valMax
                val = valMax;
            end
            S2M_rbdl_reader_coco.modifyQ(ntag, val);

        end
        function closeReader(hfigPrinc,~)
    
            % Trouver les valeurs de Q
            h = get(hfigPrinc, 'userdata');

            %delete du modele
            S2M_rbdl('delete', h.model);

            % Delete des sliders
            delete(h.sliders);

            % Delete de la fenetre principale
            delete(hfigPrinc);
        end
        function modifyQ(idx, val)
    
            % Trouver les valeurs de Q
            hfigPrinc = findobj('tag', 'figPrinc');
            h = get(hfigPrinc, 'userdata');

            % Mettre la valeur envoyée
            h.Q(idx) = val;

            % Réeregistrer dans user data
            set(hfigPrinc, 'userdata', h);

            % Update de toutes valeurs écrites et du bonhomme
            S2M_rbdl_reader_coco.updateAll;
        end
        function Q = getQ()
    
            % Trouver les valeurs de Q
            hfigPrinc = findobj('tag', 'figPrinc');
            h = get(hfigPrinc, 'userdata');

            % Mettre la valeur envoyée
            Q = h.Q;
        end
        function updateAll

            % Trouver les userdata
            hfigPrinc = findobj('tag', 'figPrinc');
            h = get(hfigPrinc, 'userdata');

            for i = 1:size(h.Q,1)
                % Changer la valeur du slider en fonction de Q
                htp = findobj('tag', sprintf('Slider_%d', i));
                set(htp, 'value', h.Q(i) );

                % Changer la valeur du VALUE en fonction de Q
                htp = findobj('tag', sprintf('Value_%d', i));
                set(htp, 'string', sprintf('%1.1f', h.Q(i) ));
            end

            % Update du bonhomme
            figure(h.figPrinc)
            h.showModel = S2M_rbdl_ShowModel_coco(h.model, h.Q, h.showModel);
            axis equal
            axis tight

            % Revoie des userdata
            set(hfigPrinc, 'userdata', h);
        end
        
    end
    properties (SetAccess = protected)
        model; 
        Q;
        figPrinc;
        sliders;
        showModel;
    end
end