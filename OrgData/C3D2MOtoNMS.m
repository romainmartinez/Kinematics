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
    % marqueurs de la boite (markers*n*dim)
Mmat(1,:,:) = btkmarkers.boite_arriere_droit;
Mmat(2,:,:) = btkmarkers.boite_arriere_gauche;
Mmat(3,:,:) = btkmarkers.boite_avant_droit;
Mmat(4,:,:) = btkmarkers.boite_avant_gauche;
Mmat(5,:,:) = btkmarkers.boite_droite_ext;
Mmat(6,:,:) = btkmarkers.boite_droite_int;
Mmat(7,:,:) = btkmarkers.boite_gauche_int;
Mmat(8,:,:) = btkmarkers.boite_gauche_ext;
    % marqueurs de la main (markers*n*dim)
Mmat(9,:,:) = btkmarkers.INDEX;
Mmat(10,:,:) = btkmarkers.LASTC;
Mmat(11,:,:) = btkmarkers.MEDH;
Mmat(12,:,:) = btkmarkers.LATH;

    % plot de la boite
plot3(Mmat(1:8,1,1), Mmat(1:8,1,2), Mmat(1:8,1,3)) ; hold on 
plot3(Mmat(1:8,1,1), Mmat(1:8,1,2), Mmat(1:8,1,3), 'b.') ; axis equal

    % Milieu M5 M6
M5M6 = Mmat(5,1,:)+Mmat(6,1,:)/2;
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

    % Position du capteur
capteur = squeeze(M5M6);
capteur = capteur+78.5*Z;

    % Matrice de rototranslation
R       = [X Y Z];
RT      = [R capteur];
RT(4,:) = [0 0 0 1];
    % plot des axes
plotAxes(RT,'length', 20)


    % Marqueurs dans le repère local
xi = invR(RT)*[squeeze(Mmat(:,1,:))';ones(1,8)];

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
    % Forces dans le global
forcein0       = R*forcemoment(1:3,:);
    % Moments dans le global (/!\ moment exprimés au centre du capteur /!\)
momentin0      = R*forcemoment(4:6,:);
    % Moments exprimés sur la main
        % milieu de la main
main = (Mmat(9,:,:)+Mmat(10,:,:)+Mmat(11,:,:)+Mmat(12,:,:))/4;         
momentin0_main = momentin0 + cross((Capteur - Main), ForceIn0);
