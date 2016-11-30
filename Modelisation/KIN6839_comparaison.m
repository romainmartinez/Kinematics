%   Description:
%       KIN6839_comparaison is used to compare inverse kinematics results
%       from RBDL, OpenSim and Anybody
%   Output:
%       KIN6839_comparaison gives plots to compare those models
%   Functions:
%       KIN6839_comparaison uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%   Date:    29-Nov-2016; Last revision: 30-Nov-2016
%_____________________________________________________________________________

clear all; close all; clc

%% Chargement des fonctions
if isempty(strfind(path, '\\10.89.24.15\e\Librairies\S2M_Lib\'))
    % Librairie S2M
    loadS2MLib;
end

% Dossier des data
Path.importPath = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\DavO\';

% Noms des fichiers data
Alias.RBDLnames = dir([Path.importPath 'RBDL\' '*.mat']);
Alias.OSnames   = dir([Path.importPath 'OpenSim\IK\' '*.mot']);
Alias.ABnames   = dir([Path.importPath 'AnyBody\' '*.txt']);

%% Chargement des données
% RBDL
Data = load([Path.importPath 'RBDL\' Alias.RBDLnames.name]);

% OpenSim
for i = 1 : length(Alias.OSnames)
    % Data
    Data.OpenSim(i).IK = importOSfile([Path.importPath 'OpenSim\IK\' Alias.OSnames(i).name], 8);
    % Header
    Data.OpenSim(i).header = {'Th_rotY', 'Th_rotX', 'Th_rotZ', 'Th_transX', 'Th_transY', 'Th_transZ',...
        'SC_y','SC_z','SC_x','AC_y','AC_z','AC_x','GH_x','GH_y','GH_z','EL_x',...
        'PS_y','wrist_dev_r','wrist_flex_r'};
end

% AnyBody
for i = 1 : length(Alias.OSnames)
    % Data
    Data.AnyBody(i).IK = importABfile([Path.importPath 'AnyBody\' Alias.ABnames(i).name]);
    % Header
    Data.AnyBody(i).header = {'SternoClavicularProtraction', 'SternoClavicularElevation', 'SternoClavicularAxialRotation',...
        'AcromioClavicularProtraction','AcromioClavicularElevation', 'AcromioClavicularAxialRotation',...
        'GlenohumeralFlexion', 'GlenohumeralExternalRotation','GlenohumeralAbduction', 'ElbowFlexion',...
        'ElbowPronation', 'WristFlexion', 'WristAbduction'};
end

%% Inverse Kinematic
% Essai
trial = 1;

% Conversion en degrés (RBDL et AnyBody seulement)
Data.RBDL(trial).selected = rad2deg(Data.RBDL(trial).selected);
Data.AnyBody(trial).IK    = rad2deg(Data.AnyBody(trial).IK);

% Sélection des DoF
% RBDL
Data.RBDL(trial).selected(:,[1:6 15 19:21]) = [];
Data.RBDL(trial).header([1:6 15 19:21]) = [];


%% Plot
% Couleurs
colors = distinguishable_colors(size(Data.OpenSim(trial).IK,2));

%% OpenSim    
for i = 1 : size(Data.OpenSim(trial).IK,2)
plot(Data.OpenSim(trial).IK(:,i),...
        'Linewidth',2,...
        'Color', colors(i,:)); 
hold on
end
title('OpenSim')
legend(Data.OpenSim(trial).header)

%% AnyBody
figure

for i = 1 : size(Data.AnyBody(trial).IK,2)
plot(Data.AnyBody(trial).IK(:,i),...
        'Linewidth',2,...
        'Color', colors(i,:)); 
hold on
end
title('AnyBody')
legend(Data.AnyBody(trial).header)

%% RBDL
figure
for i = 1 : size(Data.RBDL(trial).selected,2)
plot(Data.RBDL(trial).selected(:,i),...
        'Linewidth',2,...
        'Color', colors(i,:)); 
hold on
end
title('RBDL')
legend(Data.RBDL(trial).header)