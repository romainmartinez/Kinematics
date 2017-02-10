%   Description: used replace a missing marker in the c3d file
%   Output: gives new c3d with a replaced marker
%   Functions: uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%_____________________________________________________________________________

clear all; close all; clc

%% Chargement des fonctions
if isempty(strfind(path, '\\10.89.24.15\e\Librairies\S2M_Lib\'))
    % Librairie S2M
    loadS2MLib;
end

%% Caract�ristique
%Nom du sujet
alias.subject = myinput('Enter Subject Name');

% Dossier des essais
path.folderPath = ['\\10.89.24.15\f\Data\Shoulder\RAW\IRSST_' alias.subject 'd\trials\'];

% noms des fichiers c3d
alias.C3dfiles   = dir([path.folderPath '*.c3d']);

% Marqueur manquant
missed = 'XIPH'

%% Chargement des donn�es

for i = 2 : length(alias.C3dfiles)
    % Chargement des donn�es
    Filename   = [path.folderPath alias.C3dfiles(i).name];
    fprintf('Traitement de %d (%s)\n', i, alias.C3dfiles(i).name);
    btkc3d      = btkReadAcquisition(Filename);
    btkmarker   = btkGetMarkers(btkc3d);
    
    pointlabel = ['Naudira_' missed];
    
    btkAppendPoint(btkc3d, 'marker', pointlabel, repmat([1 1 1], length(btkmarker.Naudira_ASISr),1))
    
    btkWriteAcquisition(btkc3d, Filename)
end
