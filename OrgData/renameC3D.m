%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ____                       _         __  __            _   _                  %
% |  _ \ ___  _ __ ___   __ _(_)_ __   |  \/  | __ _ _ __| |_(_)_ __   ___ ____  %
% | |_) / _ \| '_ ` _ \ / _` | | '_ \  | |\/| |/ _` | '__| __| | '_ \ / _ \_  /  %
% |  _ < (_) | | | | | | (_| | | | | | | |  | | (_| | |  | |_| | | | |  __// /   %
% |_| \_\___/|_| |_| |_|\__,_|_|_| |_| |_|  |_|\__,_|_|   \__|_|_| |_|\___/___|  %
%                                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            clc; clear; close all
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
    for b = 1 : length(fieldnames(btkanalog))
        if sum(btkanalog.(fields{b})) == 0 
            btkanalog = rmfield(btkanalog,(fields{b}));
%             fields{b} = [];
        end
    end
%     fields = fields(~cellfun('isempty',fields));
%% Renommer les fichiers EMG
    if i == 1;
        fields = fieldnames(btkanalog);
        newlabel = xmlfile.EMGsProtocols.EMGsProtocol.MuscleList.Muscle;
        GUI_c3drename
        pause
        oldlabelEMG = oldlabel ;     
    end
    
for f = 1 : length(fieldnames(btkanalog))
btkSetAnalogLabel(btkc3d, find(strcmp(fieldnames(btkanalog), char(oldlabelEMG{f}))), Alias.Muscle{f}.Text);
end

%% Renommer les marqueurs
    if i == 1;
        fields = fieldnames(btkmarkers);
        newlabel = xmlfile.MarkersProtocols.MarkersProtocol.MarkersList.Marker;
        GUI_c3drename
        pause
        oldlabelMarkers = oldlabel ; 
    end
for u = 1 : length(fieldnames(btkmarkers))
btkSetPointLabel(btkc3d, find(strcmp(fieldnames(btkmarkers), char(oldlabelMarkers{u}))), Alias.Markers{u}.Text);
end

btkWriteAcquisition(btkc3d, Filename)
end