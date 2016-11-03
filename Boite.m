%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ____                       _         __  __            _   _                  %
% |  _ \ ___  _ __ ___   __ _(_)_ __   |  \/  | __ _ _ __| |_(_)_ __   ___ ____  %
% | |_) / _ \| '_ ` _ \ / _` | | '_ \  | |\/| |/ _` | '__| __| | '_ \ / _ \_  /  %
% |  _ < (_) | | | | | | (_| | | | | | | |  | | (_| | |  | |_| | | | |  __// /   %
% |_| \_\___/|_| |_| |_|\__,_|_|_| |_| |_|  |_|\__,_|_|   \__|_|_| |_|\___/___|  %
%                                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            clc; clear; close all; tic;
%% Chargement des fonctions
    if isempty(strfind(path, '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'))
        % Librairie S2M
            loadS2MLib;
        % Fonctions perso
            addpath(genpath('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'));
    end
%% Nom du sujet
Alias.sujet = 'dapo';  

%% Dossier des essais
folderPath = ['\\10.89.24.15\f\Data\Shoulder\RAW\IRSST_' Alias.sujet 'd\trials\'];
%% noms des fichiers c3d
C3dfiles = dir([folderPath '*.c3d']);
%% Ouvertures des c3d analogiques (EMG & Force)
    i = 1 
        FileName = [folderPath C3dfiles(i).name]; 
        btkc3d = btkReadAcquisition(FileName);
%         btkanalog = btkGetAnalogs(btkc3d);
        btkgetmarkers = btkGetMarkers(btkc3d);

M1 = btkgetmarkers.boite_arriere_droit;
M2 = btkgetmarkers.boite_arriere_gauche;
M3 = btkgetmarkers.boite_avant_droit;
M4 = btkgetmarkers.boite_avant_gauche;
M5 = btkgetmarkers.boite_droite_ext;
M6 = btkgetmarkers.boite_droite_int;
M7 = btkgetmarkers.boite_gauche_int;
M8 = btkgetmarkers.boite_gauche_ext;

M = [M1 M2 M3 M4 M5 M6 M7 M8]

plot3(M(1,1:3:end), M(1,2:3:end), M(1,3:3:end)) ; hold on 
plot3(M(1,1:3:end), M(1,2:3:end), M(1,3:3:end), 'b.')
%% Milieu boite
Milieu = (M1(1,:)+M2(1,:)+M3(1,:)+M4(1,:))/4;
plot3(Milieu(1), Milieu(2), Milieu(3), 'r.', 'markers', 12)

%% Milieu M5 M6
M5M6 = (M5(1,:)+M6(1,:))/2;
plot3(M5M6(1), M5M6(2), M5M6(3), 'r.', 'markers', 12)

%% Axes
X = M3(1,:) - M4(1,:);
X = X/norm(X);

Z = M1(1,:) - M3(1,:);
Z = Z/norm(Z);

Y = cross(Z,X);
Y = Y/norm(Y);

Z = cross(X,Y)
Z = Z/norm(Z);

R = [X' Y' Z']*10000
RT = [R Milieu']
RT(4,:) = [0 0 0 1]

plotAxes(RT)
axis equal

%% Position capteur
capteur = M5M6
capteur(2) = M5M6(2)-52
plot3(capteur(1), capteur(2), capteur(3), 'b.', 'markers', 16)
