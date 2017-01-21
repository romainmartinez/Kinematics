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
cd('C:\Users\marti\Google Drive\Codes\Kinematics\Cinematique\functions\');

%% Interrupteurs
saveresults = 0;
test        = 0;

%% Nom des sujets
Alias.sujet = sujets_valides;

for isujet = 1 %length(Alias.sujet) : -1 : 1
    
    disp(['Traitement de ' cell2mat(Alias.sujet(isujet)) ' (' num2str(length(Alias.sujet) - isujet+1) ' sur ' num2str(length(Alias.sujet)) ')'])
    %% Chemin des fichiers
    % Dossier du sujet
    Path.DirModels  = ['\\10.89.24.15\f\Data\Shoulder\Lib\' Alias.sujet{isujet} 'd\Model_2\'];
    % Dossier du modèle pour le sujet
    Path.pathModel  = [Path.DirModels 'Model.s2mMod'];
    % Dossier des data
    Path.importPath = ['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain_onlyKalman\' Alias.sujet{isujet} 'd\Trials\'];
    % Dossier d'exportation
    Path.exportPath = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\matrices\';
    % Noms des fichiers data
    Alias.Qnames    = dir([Path.importPath '*.Q*']);
    
    %% Ouverture et information du modèle
    % Ouverture du modèle
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
    
    %% Obtenir les onset et offset de force
    load(['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\' Alias.sujet{isujet} 'd\forceindex\' Alias.sujet{isujet} '_forceindex'])
    
    for itrial = length(Alias.Qnames) : -1 : 1
        %% Caractéristique de l'essai
        % Sexe du sujet
        if     length(Alias.Qnames) == 54
            Data(itrial).sexe = 'H';
        elseif length(Alias.Qnames) == 36
            Data(itrial).sexe = 'F';
        end
        
        % Noms des essais
        Data(itrial).trialname = Alias.Qnames(itrial).name(5:11);
        
        if Data(itrial).trialname(end) == '_'
            Data(itrial).trialname = Data(itrial).trialname(1:end-1);
        end
        %% Phase du mouvement
        cellfind      = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
        logical_cells = cellfun(cellfind(Data(itrial).trialname),forceindex);
        [row,~]       = find(logical_cells == 1);
        Data(itrial).start = forceindex{row,1};
        Data(itrial).end   = forceindex{row,2};
        
        %% Importation des Q,QDOT,QDDOT
        Data(itrial).Qdata = load([Path.importPath Alias.Qnames(itrial).name], '-mat');
        
        % Initialisation des Q
        if length(fieldnames(Data(itrial).Qdata)) == 3
            q1 = Data(itrial).Qdata.Q2;
        elseif length(fieldnames(Data(itrial).Qdata)) == 1
            q1 = Data(itrial).Qdata.Q1;
        end
        
    end
    
    %% Condition de l'essai
    [Data]    = getcondition(Data);
    [~,index] = sortrows([Data.condition].'); Data = Data(index); clear index
    
    %% Sauvegarde de la matrice
    if saveresults == 1
        data = rmfield(Data, 'Qdata');
        save([Path.exportPath Alias.sujet{1,isujet} '.mat'],'data')
    end
    %     clearvars data Data forceindex logical_cells
end

%% Zone de test
for iframe = 1 : length(Data(itrial).Qdata.Q2)
    TJi = S2M_rbdl('TagsJacobian', Alias.model, Data(itrial).Qdata.Q2);
    TJi  = reshape(TJi,[3,28,43]);
    TJ(:,:,iframe) = TJi(:,:,39);
end  



vGH = multiprod(TJ(:,22:24,:), Data(itrial).Qdata.QDOT2(22:24,:))
    
    %% smooth avec kalman
    T = S2M_rbdl('Tags', Alias.model, Data(itrial).Qdata.Q2);
    
    nameTags = S2M_rbdl('nameTechnicalTags', Alias.model);
    for iname = 1:length(Alias.nameTags)
        
%      idx = strfind(Alias.nameTags, nameTags{iname,1});
     
     idx(iname) = find(ismember(Alias.nameTags, nameTags{iname,1}))
    end
    
    xi = S2M_rbdl('IK_EKF', Alias.model, T(:,idx,:), zeros(28,1) , 100, 10^-10,10^-5);

    subplot(2,1,1)
   plot(Data(itrial).Qdata.Q2')
    subplot(2,1,2)
     plot(xi')