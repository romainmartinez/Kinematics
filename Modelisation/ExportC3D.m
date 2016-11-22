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

%% Chargement des c3d
cd(Path.trials)
[Path.filename,Path.trialpath] = uigetfile('*.c3d','Select the c3d file to export');
Data.btkc3d     = btkReadAcquisition([Path.trialpath Path.filename]);
Data.btkanalog  = btkGetAnalogs(Data.btkc3d);
Data.btkmarkers = btkGetMarkers(Data.btkc3d);
Data.btkforce   = btkGetForcePlatforms(Data.btkc3d);

%% Paramètre d'exportation
Alias.exportparam  = input('Enter file extension : ','s');
%% TRC (marqueurs)
    % Frequence caméra
freqcamera = 100;

    % Noms des marqueurs
markersname = fieldnames(Data.btkmarkers);

    % Matrice de marqueurs
for i = 1 : length(markersname)
    M(:,i,:) = transpose(getfield(Data.btkmarkers,markersname{i})); 
end

trcmat = transpose(reshape(M,[length(markersname)*3 length(M)]));
     
if strfind(Alias.exportparam,'trc')
    
PathFileType = 4;
name = sprintf('%s.trc', Path.filename(1:end-4));
datatype = '(X/Y/Z)';
DataRate = btkGetPointFrequency(Data.btkc3d);
CameraRate = DataRate;
NumFrames = btkGetLastFrame(Data.btkc3d);
NumMarkers = length(markersname);
Units = 'mm';
OrigDataRate = DataRate;
OrigDataStartFrame = 1;
OrigNumFrames = NumFrames;
markerset = cell(markersname);
frame = 0:1/DataRate:(NumFrames/DataRate)-1/DataRate;

% TRC File Header
% ---------------

fid = fopen(name, 'w');
if fid < 0
    fprintf('\nERROR: %s could not be opened for writing...\n\n', name);
    return
end
fprintf(fid, 'PathFileType\t%d\t%s\t%s\t\n', PathFileType, datatype, name);
fprintf(fid, 'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames\n');
fprintf(fid, '%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\n', ...
    DataRate, CameraRate, NumFrames, NumMarkers, Units, OrigDataRate, OrigDataStartFrame, OrigNumFrames);
fprintf(fid, 'Frame#\tTime\t');


% TRC File Body
% -------------

for i = 1:NumMarkers
    fprintf(fid, '%s\t\t\t', markerset{i});
end
fprintf(fid, '\n\t\t');

for i = 1:NumMarkers
    fprintf(fid, 'X%d\tY%d\tZ%d\t', i, i, i);
end
fprintf(fid, '\n\n');

for i = 1:NumFrames
    fprintf(fid, '%d\t', i);
    fprintf(fid, '%.3f\t', frame(i));
    fprintf(fid, '%.5f\t', trcmat(i,:));
    fprintf(fid, '\n');
end

fclose(fid);
fprintf('Saved (tab delimited) marker positions to: %s\n', name); 
end
%% STO (force)
if strfind(Alias.exportparam,'sto')
    
end