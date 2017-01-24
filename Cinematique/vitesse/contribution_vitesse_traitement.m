%   Description:
%       contribution_vitesse_preparation is used to compute the contribution of each
%       articulation to the acceleration
%   Output:
%       contribution_vitesse_preparation gives matrix for input in SPM1D and GRAMM
%   Functions:
%       contribution_vitesse_preparation uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
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
cd('C:\Users\marti\Documents\Codes\Kinematics\Cinematique\functions');

%% Interrupteurs
saveresults = 0;
test        = 0;
model       = 2.1;

%% Dossiers
path.Datapath = '\\10.89.24.15\e\\Projet_IRSST_LeverCaisse\ElaboratedData\matrices\cinematique\';
path.exportpath = '\\10.89.24.15\e\\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_articulation\SPM\';
alias.matname = dir([path.Datapath '*mat']);

%% Nom des sujets
alias.sujet = sujets_valides;

for isujet = 1 %length(Alias.sujet) : -1 : 1
    % Open model
    Path.DirModels  = ['\\10.89.24.15\f\Data\Shoulder\Lib\' alias.sujet{isujet} 'd\Model_' num2str(round(model)) '\' 'Model.s2mMod'];
    model = S2M_rbdl('new',Path.DirModels);
    
    % load data
    load([path.Datapath alias.sujet{isujet} '.mat']);
    
    % close model
    S2M_rbdl('delete', Alias.model);
end

%% Zone de test
for iframe = 1 : length(Data(itrial).Qdata.Q2)
    TJi = S2M_rbdl('TagsJacobian', alias.model, Data(itrial).Qdata.Q2);
    TJi  = reshape(TJi,[3,28,43]);
    TJ(:,:,iframe) = TJi(:,:,39);
end



vGH = multiprod(TJ(:,22:24,:), Data(itrial).Qdata.QDOT2(22:24,:))