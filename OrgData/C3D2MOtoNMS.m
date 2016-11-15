%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ____                       _         __  __            _   _                  %
% |  _ \ ___  _ __ ___   __ _(_)_ __   |  \/  | __ _ _ __| |_(_)_ __   ___ ____  %
% | |_) / _ \| '_ ` _ \ / _` | | '_ \  | |\/| |/ _` | '__| __| | '_ \ / _ \_  /  %
% |  _ < (_) | | | | | | (_| | | | | | | |  | | (_| | |  | |_| | | | |  __// /   %
% |_| \_\___/|_| |_| |_|\__,_|_|_| |_| |_|  |_|\__,_|_|   \__|_|_| |_|\___/___|  %
%                                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            clc; clear; close all
%% TODO : utiliser les q comme input C3D
%AC post et ant inutile , CLAV post manquaunt seulement sur Arst ?
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
    % marqueurs de la boite (dim*markers*time)
Mmat(:,1,:) = btkmarkers.boite_arriere_droit';
Mmat(:,2,:) = btkmarkers.boite_arriere_gauche';
Mmat(:,3,:) = btkmarkers.boite_avant_droit';
Mmat(:,4,:) = btkmarkers.boite_avant_gauche';
Mmat(:,5,:) = btkmarkers.boite_droite_ext';
Mmat(:,6,:) = btkmarkers.boite_droite_int';
Mmat(:,7,:) = btkmarkers.boite_gauche_int';
Mmat(:,8,:) = btkmarkers.boite_gauche_ext';
    % marqueurs de la main (dim*markers*time)
Mmat(:,9,:) = btkmarkers.INDEX';
Mmat(:,10,:) = btkmarkers.LASTC';
Mmat(:,11,:) = btkmarkers.MEDH';
Mmat(:,12,:) = btkmarkers.LATH';

    % plot de la boite
% plot3d(Mmat(:,1:8,1)); hold on
% plot3d(Mmat(:,1:8,1), 'b.'); axis equal

    % Milieu M5 M6
M5M6 = (Mmat(:,5,:)+Mmat(:,6,:))/2;
% plot3d(M5M6(:,:,1), 'r.', 'markers', 12);

    % Axes
RT = defineAxis(Mmat(:,3,:) - Mmat(:,4,:), Mmat(:,1,:) - Mmat(:,3,:), 'xz', 'x',  M5M6);
RT(1:3,4,:) = RT(1:3,3,:)*78.5+RT(1:3,4,:); % Translation de 78.5mm en z
% plotAxes(RT(:,:,1),'length', 20)
RT_Trans = invR(RT);

%% Force et moment dans le global
    % matrix 6xn des voltages
voltage(1,:) = btkanalog.Voltage_1;
voltage(2,:) = btkanalog.Voltage_2;
voltage(3,:) = btkanalog.Voltage_3;
voltage(4,:) = btkanalog.Voltage_4;
voltage(5,:) = btkanalog.Voltage_5;
voltage(6,:) = btkanalog.Voltage_6;
    % Étalonnage
matrixetal=[15.7377 -178.4176 172.9822 7.6998 -192.7411 174.1840;
                 208.3629 -109.1685 -110.3583  209.3269 -104.9032 -103.5278;
                 227.6774 222.8613 219.1087 234.3732 217.1453 221.2831;
                 5.6472 -0.7266 -0.3242 5.4650 -8.9705 -8.4179;
                 5.7700 6.7466 -6.9682 -4.1899 1.5741 -2.4571;
                 -1.2722 1.6912 -3.0543 5.1092 -5.6222 3.3049];
forcemoment    = matrixetal * voltage;
    % Reshape de la matrice de force
forcemoment = reshape(forcemoment, [6, 1, size(forcemoment,2)]);
ratioFreq = size(forcemoment, 3) / size(RT,3);
    % Forces dans le global
forcein0       = multiprod(RT_Trans(1:3,1:3,:), forcemoment(1:3,:,1:ratioFreq:end));
    % Moments dans le global (/!\ moment exprimés au centre du capteur /!\)
momentin0      = multiprod(RT_Trans(1:3,1:3,:), forcemoment(4:6,:,1:ratioFreq:end));
    % Moments exprimés dans le global     
momentin0 = momentin0 + cross(RT(1:3,4,:), forcein0);

%% Création de la force dans le C3D
    % Matrice 3D vers 2D
forcein0  = transpose(squeeze(forcein0));
momentin0 = transpose(squeeze(momentin0));
    % Interpolation pour que frame force = frame analog
oldframe = (1:size(forcein0,1))./size(forcein0,1)*100;
newframe = linspace(oldframe(1,1),100,length(btkanalog.Voltage_1));
forcein0 = interp1(oldframe,forcein0,newframe,'spline');
momentin0 = interp1(oldframe,momentin0,newframe,'spline');
    % Corners qui ne servent à rien (prit au hasard)
corners =    [0    0    0;
              0    0    0;
              0    0    0;
              0    0    0]
btkAppendForcePlatformType2_MARTINEZ(btkc3d, forcein0, momentin0, corners)
[forceplates, forceplatesInfo] = btkGetForcePlatforms(btkc3d)