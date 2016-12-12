%   Description:
%       cleanC3D is used to clean and edit c3d
%       files
%   Output:
%       cleanC3D gives clean c3d (appropriate
%       names, events, force plate)
%   Functions:
%       cleanC3D uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%   Date:    02-Nov-2016; Last revision: 15-Nov-2016
%_____________________________________________________________________________

clear all; close all; clc

%% Chargement des fonctions
if isempty(strfind(path, '\\10.89.24.15\e\Librairies\S2M_Lib\'))
    % Librairie S2M
    loadS2MLib;
end

%% Chemin des essais
% Nom du sujet
Alias.subject  = myinput('Enter Subject Name');

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
    %% Gap filling pour marqueurs
    [markers]  = interpmakers(btkmarkers);
    for mk = 1 : length(markers)
        btkSetPoint(btkc3d,mk,markers(mk).interp)
    end
    %% supprimer les analogues vides
    Names = fieldnames(btkanalog);
    delet = {};
    for loopIndex = numel(Names):-1:1
        if sum(btkanalog.(Names{loopIndex})) == 0
            btkanalog = btkRemoveAnalog(btkc3d, find(strcmp(Names,char(Names(loopIndex)))));
        end
    end
    %%
    % Déterminer si l'essai est un lever de caisse
    if strfind(lower(Filename), lower(['IRSST_' Alias.subject 'd']) )
        %% L'essai est un SCoRE ou statique
        clear oldlabel
        % Renommer les fichiers EMG
        fields   = fieldnames(btkanalog);
        newlabel = xmlfile.EMGsProtocols.EMGsProtocol.MuscleList.Muscle;
        GUI_c3drename
        pause
        oldlabelEMG_SCoRE = oldlabel;
        
        oldlabelEMG_SCoRE   = oldlabelEMG_SCoRE(~cellfun('isempty',oldlabelEMG_SCoRE));
        for f = 1 : length(oldlabelEMG_SCoRE)
            btkSetAnalogLabel(btkc3d, find(strcmp(fieldnames(btkanalog),char(oldlabelEMG_SCoRE{f}))), Alias.Muscle{f}.Text);
        end
        
        % Renommer les marqueurs
        fields   = fieldnames(btkmarkers);
        newlabel = xmlfile.MarkersProtocols.MarkersProtocol.MarkersList.Marker;
        GUI_c3drename
        pause
        oldlabelMarkers = oldlabel;
        oldlabelMarkers = oldlabelMarkers(~cellfun('isempty',oldlabelMarkers));
        for   u = 1 : length(oldlabelMarkers)
            btkSetPointLabel(btkc3d, find(strcmp(fieldnames(btkmarkers), char(oldlabelMarkers{u}))), Alias.Markers{u}.Text);
        end
    else
        %% L'essai est un lever de caisse
        % Renommer les fichiers EMG
        if i == 1;
            fields   = fieldnames(btkanalog);
            newlabel = xmlfile.EMGsProtocols.EMGsProtocol.MuscleList.Muscle;
            GUI_c3drename
            pause
            oldlabelEMG = oldlabel ;
        end
        
        oldlabelEMG   = oldlabelEMG(~cellfun('isempty',oldlabelEMG));
        for f = 1 : length(oldlabelEMG)
            btkSetAnalogLabel(btkc3d, find(strcmp(fieldnames(btkanalog),char(oldlabelEMG{f}))), Alias.Muscle{f}.Text);
        end
        
        % Renommer les marqueurs
        if i == 1;
            fields   = fieldnames(btkmarkers);
            newlabel = xmlfile.MarkersProtocols.MarkersProtocol.MarkersList.Marker;
            GUI_c3drename
            pause
            oldlabelMarkers = oldlabel ;
        end
        
        oldlabelMarkers = oldlabelMarkers(~cellfun('isempty',oldlabelMarkers)) ;
        for   u = 1 : length(oldlabelMarkers)
            btkSetPointLabel(btkc3d, find(strcmp(fieldnames(btkmarkers), char(oldlabelMarkers{u}))), Alias.Markers{u}.Text);
        end
        
        %% Transport des forces et moments dans le global
        btkanalog  = btkGetAnalogs(btkc3d);
        btkmarkers = btkGetMarkers(btkc3d);
        
        % Plot de la boite (0 pour ne pas ploter)
        tagplot    = 0;
        
        % Exprimer les forces dans le global et rebase, détecter les phases
        [ forcein0, momentin0, corners, premier, dernier ] = forceinglobal( btkmarkers, btkanalog, tagplot);
        
        % Création d'une plateforme virtuelle dans le c3d en cours
        btkAppendForcePlatformType2_MARTINEZ(btkc3d, forcein0, momentin0, corners);
        
        %% Création des events dans le C3D
        btkAppendEvent(btkc3d, 'extract', premier/2000, 'extract');
        btkAppendEvent(btkc3d, 'storage', dernier/2000, 'storage');
    end
    %% Édition du C3D
    btkWriteAcquisition(btkc3d, Filename)
end

% forces = btkGetForcePlatforms(btkc3d);
% forcein0 = [forces.channels.Fx1 forces.channels.Fy1 forces.channels.Fz1 ...
%             forces.channels.My1 forces.channels.My1 forces.channels.Mz1];
%     % Interpolation pour que frame force = frame analog
% oldframe  = (1:size(forcein0,1))./size(forcein0,1)*100;
% newframe  = linspace(oldframe(1,1),100,length(btkmarkers.ACRO_tip));
% forcein0  = interp1(oldframe,forcein0,newframe,'spline');