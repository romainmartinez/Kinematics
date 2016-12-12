%   Description:
%       contribution_hauteur_traitement is used replace a missing marker in
%       the c3d file
%   Output:
%       contribution_hauteur gives new c3d with a replaced marker
%   Functions:
%       contribution_hauteur uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%   Date:    12-Dec-2016; Last revision: 12-Dec-2016
%_____________________________________________________________________________

clear all; close all; clc

%% Chargement des fonctions
if isempty(strfind(path, '\\10.89.24.15\e\Librairies\S2M_Lib\'))
    % Librairie S2M
    loadS2MLib;
end

%% Nom du sujet
Alias.sujet = myinput('Enter Subject Name');

% Chemin des essais
Path.trials    = ['\\10.89.24.15\e\Projet_IRSST_LeverCaisse\InputData\' Alias.subject '\'];
Alias.C3dfiles = dir([Path.trials '*.c3d']);

%% Chargement des données

for i = 1 : length(Alias.C3dfiles)
    Filename   = [Path.trials Alias.C3dfiles(i).name];
    fprintf('Traitement de %d (%s)\n', i, Alias.C3dfiles(i).name);
    btkc3d     = btkReadAcquisition(Filename);
    btkanalog  = btkGetAnalogs(btkc3d);
    btkmarkers = btkGetMarkers(btkc3d);
end