%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ____                       _         __  __            _   _                  %
% |  _ \ ___  _ __ ___   __ _(_)_ __   |  \/  | __ _ _ __| |_(_)_ __   ___ ____  %
% | |_) / _ \| '_ ` _ \ / _` | | '_ \  | |\/| |/ _` | '__| __| | '_ \ / _ \_  /  %
% |  _ < (_) | | | | | | (_| | | | | | | |  | | (_| | |  | |_| | | | |  __// /   %
% |_| \_\___/|_| |_| |_|\__,_|_|_| |_| |_|  |_|\__,_|_|   \__|_|_| |_|\___/___|  %
%                                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            clc; clear; close all 
                            
%% Chemin de la librairie et des fichiers
    % Chargement des fonctions
    if isempty(strfind(path, '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'))
        % Librairie S2M
            loadS2MLib;
        % Fonctions perso
            addpath(genpath('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'));
    end
    
     % Dossier des data
Path.importPath = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\DavO\';

    % Noms des fichiers data
Alias.RBDLnames = dir([Path.importPath 'RBDL\' '*.mat']);
Alias.OSnames = dir([Path.importPath 'OpenSim\IK\' '*.mot']);

%% Chargement des données
    % RBDL
Data = load([Path.importPath 'RBDL\' Alias.RBDLnames.name]);

    % OpenSim   
for i = 1 : length(Alias.OSnames)
    Data.OpenSim(i).IK = importOSfile([Path.importPath 'OpenSim\IK\' Alias.OSnames(i).name], 8);
    Data.OpenSim(i).header = {'SC_y','SC_z','SC_x','AC_y','AC_z','AC_x','GH_x','GH_y','GH_z','EL_x','PS_y','wrist_dev_r','wrist_flex_r'};
end

%% Inverse Kinematic
trial = 1;  
    % Traitement des données
    
    % Sélection des DoF
        % RBDL
      
Data.RBDL(trial).selected(:,[1:12 15 19:21]) = [];
Data.RBDL(trial).header([1:12 15 19:21]) = [];

colors = distinguishable_colors(size(Data.OpenSim(trial).IK,2));

for i = 1 : size(Data.RBDL(trial).selected,2)
plot(Data.RBDL(trial).selected(:,i),...
        'Linewidth',2,...
        'Color', colors(i,:)); 
hold on
end
title('RBDL')
legend(Data.RBDL(trial).header)

        % OpenSim
Data.OpenSim(trial).IK(:,[1:6]) = [];     

figure

for i = 1 : size(Data.OpenSim(trial).IK,2)
plot(Data.OpenSim(trial).IK(:,i),...
        'Linewidth',2,...
        'Color', colors(i,:)); 
hold on
end
title('OpenSim')
legend(Data.OpenSim(trial).header)
