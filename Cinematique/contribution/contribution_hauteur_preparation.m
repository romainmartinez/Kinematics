%   Description: used to compute the contribution of each articulation to the height
%   Output: gives matrix for input in SPM1D and GRAMM
%   Functions: uses functions present in //10.89.24.15/e/Project_IRSST_LeverCaisse/Codes/Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%_____________________________________________________________________________

clear variables; close all; clc

path2 = load_functions('linux', 'Kinematics/Cinematique');

%% Interrupteurs
saveresults = 1;
anato       = 1;
model       = 2.1;

%% Nom des sujets
alias.sujet = IRSST_participants('IRSST');

for isujet = length(alias.sujet) : -1 : 1
    
    disp(['Traitement de ' cell2mat(alias.sujet(isujet)) ' (' num2str(length(alias.sujet) - isujet+1) ' sur ' num2str(length(alias.sujet)) ')'])
    %% Chemin des fichiers
    % Dossier du sujet
    path2.DirModels  = [path2.F '/Data/Shoulder/Lib/' alias.sujet{isujet} 'd/Model_' num2str(round(model)) '/' 'Model.s2mMod'];
    % Dossier des data
    path2.importPath = [path2.E '/Projet_Reconstructions/DATA/Romain/' alias.sujet{isujet} 'd/trials/'];
    % Dossier d'exportation
    path2.exportPath = [path2.E '/Projet_IRSST_LeverCaisse/ElaboratedData/matrices/'];
    % Noms des fichiers data
    alias.Qnames    = dir([path2.importPath '*_MOD' num2str(model) '_*' 'r' '*.Q*']);
    
    %% Ouverture et information du mod�le
    % Ouverture du mod�le
    alias.model    = S2M_rbdl('new',path2.DirModels);
    % Noms et nombre de DoF
    alias.nameDof  = S2M_rbdl('nameDof', alias.model);
    alias.nDof     = S2M_rbdl('nDof', alias.model);
    % Noms et nombre de marqueurs
    alias.nameTags = S2M_rbdl('nameTags', alias.model);
    alias.nTags    = S2M_rbdl('nTags', alias.model);
    % Nom des segments
    alias.nameBody = S2M_rbdl('nameBody', alias.model);
    [alias.segmentMarkers, alias.segmentDoF] = segment_RBDL(round(model));
    
    
    %% Anatomical position correction
    if anato == 1
        save_fig = 0;
        [q_correct] = anatomical_correction(alias.sujet{isujet}, model, alias.model, save_fig, path2);
    elseif anato == 0
        q_correct = 0;
    end
    
    %% Obtenir les onset et offset de force
    load([path2.E '/Projet_IRSST_LeverCaisse/ElaboratedData/matrices/forceindex/' alias.sujet{isujet} '_forceindex.mat'])
    for trial = length(alias.Qnames) : -1 : 1
        %% Caract�ristique de l'essai
        % Sexe du sujet
        if     length(alias.Qnames) == 54
            Data(trial).sexe = 'H';
        elseif length(alias.Qnames) == 36
            Data(trial).sexe = 'F';
        end
        
        % Noms des essais
        Data(trial).trialname = alias.Qnames(trial).name(5:11);
        
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
        Data(trial).Qdata = load([path2.importPath alias.Qnames(trial).name], '-mat');
        
        %% Contribution des articulation � la hauteur
        % Initialisation des Q
        if length(fieldnames(Data(trial).Qdata)) == 3
            q1 = Data(trial).Qdata.Q2(:,round(Data(trial).start:Data(trial).end));
        elseif length(fieldnames(Data(trial).Qdata)) == 1
            q1 = Data(trial).Qdata.Q1(:,round(Data(trial).start:Data(trial).end));
        end
        
        %% Filtre passe-bas 15Hz
        q1 = transpose(lpfilter(q1', 15, 100));
        
        %% Articulation 1 : Poignet + coude
        % Coordonn�es des marqueurs dans le rep�re global
        T = S2M_rbdl('Tags', alias.model, q1);
        
        % Marqueurs du segment en cours ('3' correspond � Z car on s'int�resse � la hauteur)
        Data(trial).H(:,:,1) = squeeze(T(3,39,:));
        
        % position verticale au moment de la prise et l�ch� caisse (pour normalisation plus tard)
        Data(trial).normalization = [Data(trial).H(1,:,1) Data(trial).H(end,:,1)];
        
        % Blocage des q du segment
        q1(alias.segmentDoF.handelbow,:) = repmat(q_correct(alias.segmentDoF.handelbow), 1, length(q1));
        
        % Redefinition des marqueurs avec les q bloqu�s
        T = S2M_rbdl('Tags', alias.model, q1);
        
        % Marqueurs du segment en cours avec q bloqu�s
        Data(trial).H(:,:,2) = squeeze(T(3,39,:));
              
        %% Articulation 2 : GH
        % Blocage des q du segment
        q1(alias.segmentDoF.GH,:) = repmat(q_correct(alias.segmentDoF.GH), 1, length(q1));
        
        % Redefinition des marqueurs avec les q bloqu�s
        T = S2M_rbdl('Tags', alias.model,q1);
        
        % Marqueurs du segment en cours avec q bloqu�s
        Data(trial).H(:,:,3) = squeeze(T(3,39,:));
              
        %% Articulation 3 : GH
        % Blocage des q du segment
        q1(alias.segmentDoF.SCAC,:) = repmat(q_correct(alias.segmentDoF.SCAC), 1, length(q1));
        
        % Redefinition des marqueurs avec les q bloqu�s
        T = S2M_rbdl('Tags', alias.model, q1);
        
        % Marqueurs du segment en cours avec q bloqu�s
        Data(trial).H(:,:,4) = squeeze(T(3,39,:));
             
        %% Articulation 4 : Reste du corps (pelvis + thorax)
        % Blocage des q du segment
        q1(alias.segmentDoF.RoB,:) = repmat(q_correct(alias.segmentDoF.RoB), 1, length(q1));
        
        % Redefinition des marqueurs avec les q bloqu�s
        T = S2M_rbdl('Tags', alias.model, q1);
        
        % Marqueurs du segment en cours avec q bloqu�s
        Data(trial).H(:,:,5) = squeeze(T(3,39,:));
      
    end
    
    %% Condition de l'essai
    [Data]    = getcondition(Data);
    [~,index] = sortrows([Data.condition].'); Data = Data(index); clear index
    
    S2M_rbdl('delete', alias.model);
    
    %% calcul de la contribution � la hauteur
    Data = contrib_height(Data);

    %% Sauvegarde de la matrice
    if saveresults == 1
        % hauteur
        temp = rmfield(Data,{'Qdata','normalization','H'});
        save([path2.exportPath 'hauteur/' alias.sujet{1,isujet} '.mat'],'temp')
        clearvars temp
        % cin�matique
        temp = rmfield(Data, {'deltahand', 'deltaGH', 'deltaSCAC', 'deltaRoB','normalization','H'});
        save([path2.exportPath 'cinematique/' alias.sujet{1,isujet} '.mat'],'temp')
        clearvars temp
    end
    
    clearvars data Data forceindex logical_cells H1 H2 H3 H4 H5 q1 T
end