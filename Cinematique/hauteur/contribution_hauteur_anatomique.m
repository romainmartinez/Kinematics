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
Alias.sujet = sujets_valides;

for isubject = length(Alias.sujet) : -1 : 1
    %% Chemin des fichiers
    % Dossier du sujet
    Path.DirModels  = ['\\10.89.24.15\f\Data\Shoulder\Lib\' Alias.sujet{isubject} 'd\Model_2\'];
    % Dossier du mod�le pour le sujet
    Path.pathModel  = [Path.DirModels 'Model.s2mMod'];
    % Dossier des data
    Path.importPath = ['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\' Alias.sujet{isubject} 'd\MODEL2\'];
    % Dossier d'exportation
    Path.exportPath = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_hauteur\elaboratedData_mat\';
    % Noms des fichiers data
    Alias.Qnames    = dir([Path.importPath '*.Q1']);
    
    %% Ouverture et information du mod�le
    % Ouverture du mod�le
    Alias.model    = S2M_rbdl('new',Path.pathModel);
    % Noms et nombre de DoF
    Alias.nameDof  = S2M_rbdl('nameDof', Alias.model);
    Alias.nDof     = S2M_rbdl('nDof', Alias.model);
    % Noms et nombre de marqueurs
    Alias.nameTags = S2M_rbdl('nameTags', Alias.model);
    Alias.nTags    = S2M_rbdl('nTags', Alias.model);
    % Nom des segments
    Alias.nameBody = S2M_rbdl('nameBody', Alias.model);
    [Alias.segmentMarkers, Alias.segmentDoF] = segment_RBDL;
    
    %% Ouverture des donn�es
    Data.Qdata = load([Path.importPath Alias.Qnames.name], '-mat');
    
    %% test
    Data.Q0 = mean(Data.Qdata.Q1,2);
    [q] = positionanato(Data.Q0, Alias.model)
    
end
S2M_rbdl_ShowModel(Alias.model, Data.Q0, 'rt', true, 'comi', false, 'tags', true, 'com', false)
axis equal