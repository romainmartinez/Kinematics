%   Description: used to compute the contribution of each articulation to the height
%   Output: gives matrix for input in SPM1D and GRAMM
%   Functions: uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%_____________________________________________________________________________

clear variables; close all; clc

%% Chargement des fonctions
if ~contains(path, '\\10.89.24.15\e\Librairies\S2M_Lib\')
    % Librairie S2M
    loadS2MLib;
end

% Fonctions locales
cd('C:\Users\marti\Documents\Codes\Kinematics\Cinematique\functions');

%% Interrupteurs
saveresults = 1;
anato       = 1;
model       = 2.1;

%% Nom des sujets
Alias.sujet = sujets_valides;

for isujet = length(Alias.sujet) : -1 : 1
    
    disp(['Traitement de ' cell2mat(Alias.sujet(isujet)) ' (' num2str(length(Alias.sujet) - isujet+1) ' sur ' num2str(length(Alias.sujet)) ')'])
    %% Chemin des fichiers
    % Dossier du sujet
    Path.DirModels  = ['\\10.89.24.15\f\Data\Shoulder\Lib\' Alias.sujet{isujet} 'd\Model_' num2str(round(model)) '\'];
    % Dossier du modèle pour le sujet
    Path.pathModel  = [Path.DirModels 'Model.s2mMod'];
    % Dossier des data
    Path.importPath = ['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\' Alias.sujet{isujet} 'd\Trials\'];
    % Dossier d'exportation
    Path.exportPath = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\matrices\';
    % Noms des fichiers data
    Alias.Qnames    = dir([Path.importPath '*_MOD' num2str(model) '_*' 'r' '*.Q*']);
    
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
    [Alias.segmentMarkers, Alias.segmentDoF] = segment_RBDL(round(model));
    
    
    %% Anatomical position correction
    if anato == 1
        save_fig = 0;
        [q_correct] = anatomical_correction(Alias.sujet{isujet}, model, Alias.model, save_fig);
    elseif anato == 0
        q_correct = 0;
    end
    
    %% Obtenir les onset et offset de force
    load(['\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\matrices\forceindex\' cell2mat(Alias.sujet(isujet)) '_forceindex.mat'])
    for trial = length(Alias.Qnames) : -1 : 1
        %% Caractéristique de l'essai
        % Sexe du sujet
        if     length(Alias.Qnames) == 54
            Data(trial).sexe = 'H';
        elseif length(Alias.Qnames) == 36
            Data(trial).sexe = 'F';
        end
        
        % Noms des essais
        Data(trial).trialname = Alias.Qnames(trial).name(5:11);
        
        if Data(trial).trialname(end) == '_'
            Data(trial).trialname = Data(trial).trialname(1:end-1);
        end
        %% Phase du mouvement
        cellfind      = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
        logical_cells = cellfun(cellfind(Data(trial).trialname),forceindex);
        [row,~]       = find(logical_cells == 1);
        Data(trial).start = forceindex{row,1};
        Data(trial).end   = forceindex{row,2};
        Data(trial).time   = forceindex{row,4};
        
        %% Importation des Q,QDOT,QDDOT
        Data(trial).Qdata = load([Path.importPath Alias.Qnames(trial).name], '-mat');
        
        %% Contribution des articulation à la hauteur
        % Initialisation des Q
        if length(fieldnames(Data(trial).Qdata)) == 3
            q1 = Data(trial).Qdata.Q2(:,round(Data(trial).start:Data(trial).end));
        elseif length(fieldnames(Data(trial).Qdata)) == 1
            q1 = Data(trial).Qdata.Q1(:,round(Data(trial).start:Data(trial).end));
        end
        
        %% Filtre passe-bas 15Hz
        q1 = transpose(lpfilter(q1', 15, 100));
        
        %% Articulation 1 : Poignet + coude
        % Coordonnées des marqueurs dans le repère global
        T = S2M_rbdl('Tags', Alias.model, q1);
        
        % Marqueurs du segment en cours ('3' correspond à Z car on s'intéresse à la hauteur)
        Data(trial).H(:,:,1) = squeeze(T(3,39,:));
        Data(trial).boite = Data(trial).H(:,:,1);
        
        % position verticale au moment de la prise et lâché caisse (pour normalisation plus tard)
        Data(trial).normalization = [Data(trial).H(1,:,1) Data(trial).H(end,:,1)];
        
        % Blocage des q du segment
        q1(Alias.segmentDoF.handelbow,:) = repmat(q_correct(Alias.segmentDoF.handelbow), 1, length(q1));
        
        % Redefinition des marqueurs avec les q bloqués
        T = S2M_rbdl('Tags', Alias.model, q1);
        
        % Marqueurs du segment en cours avec q bloqués
        Data(trial).H(:,:,2) = squeeze(T(3,39,:));
              
        %% Articulation 2 : GH
        % Blocage des q du segment
        q1(Alias.segmentDoF.GH,:) = repmat(q_correct(Alias.segmentDoF.GH), 1, length(q1));
        
        % Redefinition des marqueurs avec les q bloqués
        T = S2M_rbdl('Tags', Alias.model,q1);
        
        % Marqueurs du segment en cours avec q bloqués
        Data(trial).H(:,:,3) = squeeze(T(3,39,:));
              
        %% Articulation 3 : GH
        % Blocage des q du segment
        q1(Alias.segmentDoF.SCAC,:) = repmat(q_correct(Alias.segmentDoF.SCAC), 1, length(q1));
        
        % Redefinition des marqueurs avec les q bloqués
        T = S2M_rbdl('Tags', Alias.model, q1);
        
        % Marqueurs du segment en cours avec q bloqués
        Data(trial).H(:,:,4) = squeeze(T(3,39,:));
             
        %% Articulation 4 : Reste du corps (pelvis + thorax)
        % Blocage des q du segment
        q1(Alias.segmentDoF.RoB,:) = repmat(q_correct(Alias.segmentDoF.RoB), 1, length(q1));
        
        % Redefinition des marqueurs avec les q bloqués
        T = S2M_rbdl('Tags', Alias.model, q1);
        
        % Marqueurs du segment en cours avec q bloqués
        Data(trial).H(:,:,5) = squeeze(T(3,39,:));
      
    end
    
    %% Condition de l'essai
    [Data]    = getcondition(Data);
    [~,index] = sortrows([Data.condition].'); Data = Data(index); clear index
    
    S2M_rbdl('delete', Alias.model);
    
    %% calcul de la contribution à la hauteur
    Data = contrib_height(Data);

    %% Sauvegarde de la matrice
    if saveresults == 1
        % hauteur
        temp = rmfield(Data,{'Qdata','normalization','H'});
        save([Path.exportPath 'hauteur\' Alias.sujet{1,isujet} '.mat'],'temp')
        clearvars temp
        % cinématique
        temp = rmfield(Data, {'deltahand', 'deltaGH', 'deltaSCAC', 'deltaRoB','normalization','H'});
        save([Path.exportPath 'cinematique\' Alias.sujet{1,isujet} '.mat'],'temp')
        clearvars temp
    end
    
    clearvars data Data forceindex logical_cells H1 H2 H3 H4 H5 q1 T
end