%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ____                       _         __  __            _   _                  %
% |  _ \ ___  _ __ ___   __ _(_)_ __   |  \/  | __ _ _ __| |_(_)_ __   ___ ____  %
% | |_) / _ \| '_ ` _ \ / _` | | '_ \  | |\/| |/ _` | '__| __| | '_ \ / _ \_  /  %
% |  _ < (_) | | | | | | (_| | | | | | | |  | | (_| | |  | |_| | | | |  __// /   %
% |_| \_\___/|_| |_| |_|\__,_|_|_| |_| |_|  |_|\__,_|_|   \__|_|_| |_|\___/___|  %
%                                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            clc; clear; close all
%% TODO : AC post et ant inutile , CLAV post manquaunt seulement sur Arst ?
%% Chargement des fonctions
    if isempty(strfind(path, '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'))
        % Librairie S2M
            loadS2MLib;
        % Fonctions perso
            addpath(genpath('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'));
    end
    
%% Chemin des essais
    % Nom du sujet
Alias.subject  = input('Enter subject name : ','s');
    % Chemin des essais
Path.trials    = ['\\10.89.24.15\e\Projet_IRSST_LeverCaisse\InputData\' Alias.subject '\'];
Alias.C3dfiles = dir([Path.trials '*.c3d']); 

%% Chargement des fichiers de configuration
    % Configuration du set de marqueurs
    xmlfile.MarkersProtocols = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab\MOtoNMS\SetupFiles\AcquisitionInterface\MarkersProtocols\S2M_IRSST_ALL_Markers.xml';
    xmlfile.MarkersProtocols = xml2struct( xmlfile.MarkersProtocols );
    Alias.Markers            = xmlfile.MarkersProtocols.MarkersProtocol.MarkersList.Marker;
    % Configuration des EMG
    xmlfile.EMGsProtocols    = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab\MOtoNMS\SetupFiles\AcquisitionInterface\EMGsProtocols\S2M_IRSST_EMG.xml';
    xmlfile.EMGsProtocols    = xml2struct( xmlfile.EMGsProtocols );
    Alias.Muscle             = xmlfile.EMGsProtocols.EMGsProtocol.MuscleList.Muscle;

%% Chargement des c3d

for i = 1 : length(Alias.C3dfiles)
Filename   = [Path.trials Alias.C3dfiles(i).name];
fprintf('Traitement de %d (%s)\n', i, Alias.C3dfiles(i).name);
btkc3d     = btkReadAcquisition(Filename);
btkanalog  = btkGetAnalogs(btkc3d);
btkmarkers = btkGetMarkers(btkc3d);
%% supprimer les analogues vides
Names = fieldnames(btkanalog);
delet = {};
for loopIndex = numel(Names):-1:1  %1 : numel(Names) 
    if sum(btkanalog.(Names{loopIndex})) == 0
        btkanalog = btkRemoveAnalog(btkc3d, find(strcmp(Names,char(Names(loopIndex))))); 
    end
end
% %% Renommer les fichiers EMG
%     if i == 1;
%         fields   = fieldnames(btkanalog);
%         newlabel = xmlfile.EMGsProtocols.EMGsProtocol.MuscleList.Muscle;
%         GUI_c3drename
%         pause
%         oldlabelEMG = oldlabel ;
%     end
% 
% oldlabelEMG = oldlabelEMG(~cellfun('isempty',oldlabelEMG));
%         for f = 1 : length(oldlabelEMG)
%             btkSetAnalogLabel(btkc3d, find(strcmp(fieldnames(btkanalog),char(oldlabelEMG{f}))), Alias.Muscle{f}.Text);
%         end
% 
% %% Renommer les marqueurs
%     if i == 1;
%         fields   = fieldnames(btkmarkers);
%         newlabel = xmlfile.MarkersProtocols.MarkersProtocol.MarkersList.Marker;
%         GUI_c3drename
%         pause
%         oldlabelMarkers = oldlabel ; 
%     end
%     
% oldlabelMarkers = oldlabelMarkers(~cellfun('isempty',oldlabelMarkers)) ;    
%         for u = 1 : length(oldlabelMarkers)
%             btkSetPointLabel(btkc3d, find(strcmp(fieldnames(btkmarkers), char(oldlabelMarkers{u}))), Alias.Markers{u}.Text);
%         end
% 
% btkWriteAcquisition(btkc3d, Filename)
end

%% Force
    % marqueurs de la boite
% M1 = btkmarkers.boite_arriere_droit;
% M2 = btkmarkers.boite_arriere_gauche;
% M3 = btkmarkers.boite_avant_droit;
% M4 = btkmarkers.boite_avant_gauche;
% M5 = btkmarkers.boite_droite_ext;
% M6 = btkmarkers.boite_droite_int;
% M7 = btkmarkers.boite_gauche_int;
% M8 = btkmarkers.boite_gauche_ext;
% 
% M = [M1 M2 M3 M4 M5 M6 M7 M8];

Mmat(1,:,:) = btkmarkers.boite_arriere_droit;
Mmat(2,:,:) = btkmarkers.boite_arriere_gauche;
Mmat(3,:,:) = btkmarkers.boite_avant_droit;
Mmat(4,:,:) = btkmarkers.boite_avant_gauche;
Mmat(5,:,:) = btkmarkers.boite_droite_ext;
Mmat(6,:,:) = btkmarkers.boite_droite_int;
Mmat(7,:,:) = btkmarkers.boite_gauche_int;
Mmat(8,:,:) = btkmarkers.boite_gauche_ext;

    % plot de la boite
plot3(Mmat(:,1,1), Mmat(:,1,2), Mmat(:,1,3)) ; hold on 
plot3(Mmat(:,1,1), Mmat(:,1,2), Mmat(:,1,3), 'b.')
    % Milieu boite
Milieu = (Mmat(1,1,:)+Mmat(2,1,:)+Mmat(3,1,:)+Mmat(4,1,:))/4;    
plot3(Milieu(1), Milieu(2), Milieu(3), 'r.', 'markers', 12)

    % Milieu M5 M6
M5M6 = (Mmat(5,1,:)+Mmat(6,1,:))/2;
plot3(M5M6(1), M5M6(2), M5M6(3), 'r.', 'markers', 12)

    % Axes
X = squeeze(Mmat(3,1,:) - Mmat(4,1,:));
X = X/norm(X);

Z = squeeze(Mmat(1,1,:) - Mmat(3,1,:));
Z = Z/norm(Z);

Y = cross(Z,X);
Y = Y/norm(Y);

Z = cross(X,Y);
Z = Z/norm(Z);

capteur = squeeze(M5M6);
capteur = capteur+78.5*Z;


R = [X Y Z];
RT = [R capteur];
RT(4,:) = [0 0 0 1];

plotAxes(RT,'length', 20)
axis equal

%% Test
xi = invR(RT)*[squeeze(Mmat(:,1,:))';ones(1,8)]


% matrix 6xn
voltage(1,:) = btkanalog.Voltage_1;

ForceMoment = MatrixEtal * voltages;
ForceIn0 = R*ForcesInL(1:3,:);
MomentIn0 = R*ForcesInL(4:6,:); % attention moment exprimé au centre du capteur

%Main point sur la main
%Capteur centre du capteur

MomentIn0_Main = MomentIn0 + cross((Capteur - Main), ForceIn0);



    % Position capteur
plot3(capteur(1), capteur(2), capteur(3), 'b.', 'markers', 16)