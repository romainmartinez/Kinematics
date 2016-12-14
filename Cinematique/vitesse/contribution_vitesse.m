%   Description:
%       contribution_vitesse is used 
%   Output:
%       contribution_vitesse gives 
%   Functions:
%       contribution_vitesse uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%   Date:    14-Dec-2016; Last revision: 14-Dec-2016
%_____________________________________________________________________________

clear all; close all; clc

%% Chargement des fonctions
if isempty(strfind(path, '\\10.89.24.15\e\Librairies\S2M_Lib\'))
    % Librairie S2M
    loadS2MLib;
end

%% Interrupteurs


%% Nom du sujet
Alias.sujet = myinput('Enter Subject Name');

%% Chemin des fichiers
% Dossier du sujet
Path.DirModels  = ['\\10.89.24.15\f\Data\Shoulder\Lib\IRSST_' Alias.sujet 'd\Model_2\'];
% Dossier du modèle pour le sujet
Path.pathModel  = [Path.DirModels 'Model.s2mMod'];
% Dossier des data
Path.importPath = ['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\IRSST_' Alias.sujet 'd\Trials\'];
% Dossier d'exportation
Path.exportPath = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_hauteur\elaboratedData_mat\';
% Noms des fichiers data
Alias.Qnames    = dir([Path.importPath '*.Q*']);

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
        
%% 
trial = 1;

Qdata     = load([Path.importPath Alias.Qnames(trial).name], '-mat');
for i = 1 : 553
    TJ = S2M_rbdl('TagsJacobian', Stuff.model, Qdata.Q2)
    TJ = reshape(TJ,[3,28,43])
    TJ = TJ(:,:,39)
    
    vGH = multiprod(TJ, Qdata.QDOT2  )
end