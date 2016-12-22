%   Description:
%       contribution_hauteur_anatomique is used to compute the anatomical
%       position
%   Output:
%       contribution_hauteur_preparation gives Q0
%   Functions:
%       contribution_hauteur_preparation uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
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

% Fonctions locales
cd('C:\Users\marti\Google Drive\Codes\Kinematics\Cinematique\functions\')

%% Interrupteurs


%% Nom du sujet
Alias.sujet = dir(['\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_hauteur\elaboratedData_mat\' '*mat']);
Alias.sujet = cellstr(vertcat(Alias.sujet(:).name));
Alias.sujet = cellfun(@(x){x(1:end-4)}, Alias.sujet);

for isubject = length(Alias.sujet) : -1 : 1
    %% Chemin des fichiers
    % Dossier du sujet
    Path.DirModels  = ['\\10.89.24.15\f\Data\Shoulder\Lib\IRSST_' Alias.sujet{isubject} 'd\Model_2\'];
    % Dossier du modèle pour le sujet
    Path.pathModel  = [Path.DirModels 'Model.s2mMod'];
    % Dossier des data
    Path.importPath = ['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\IRSST_' Alias.sujet{isubject} 'd\MODEL2\'];
    % Dossier d'exportation
    Path.exportPath = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_hauteur\elaboratedData_mat\';
    % Noms des fichiers data
    Alias.Qnames    = dir([Path.importPath '*.Q1']);
    
    %% Ouverture et information du modèle
    % Ouverture du modèle
    Stuff.model    = S2M_rbdl('new',Path.pathModel);
    % Noms et nombre de DoF
    Alias.nameDof  = S2M_rbdl('nameDof', Stuff.model);
    Alias.nDof     = S2M_rbdl('nDof', Stuff.model);
    % Noms et nombre de marqueurs
    Alias.nameTags = S2M_rbdl('nameTags', Stuff.model);
    Alias.nTags    = S2M_rbdl('nTags', Stuff.model);
    % Nom des segments
    Alias.nameBody = S2M_rbdl('nameBody', Stuff.model);
    % identification des marqueurs correspondant à chaque segement
    % handelbow
    Alias.segmentMarkers.handelbow = 32:43;
    % GH
    Alias.segmentMarkers.GH        = 25:31;
    % SCAC
    Alias.segmentMarkers.SCAC      = 11:24;
    % RoB
    Alias.segmentMarkers.RoB       = 1:10;
    % identification des DoF correspondant à chaque segement
    % handelbow
    Alias.segmentDoF.handelbow     = 25:28;
    % GH
    Alias.segmentDoF.GH            = 19:24;
    % SCAC
    Alias.segmentDoF.SCAC          = 13:18;
    % RoB
    Alias.segmentDoF.RoB           = 1:12;
    
    %% Ouverture des données
    Data.Qdata = load([Path.importPath Alias.Qnames.name], '-mat');
    
    %% test
    Data.Q0 = mean(Data.Qdata.Q1,2)
[q] = positionanato(Data.Q0)
    
end
