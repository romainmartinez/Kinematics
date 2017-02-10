%   Description: used to compute the contribution of each articulation to the height
%   Output: gives matrix for input in SPM1D and GRAMM
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

% Fonctions locales
cd('C:\Users\marti\Documents\Codes\Kinematics\Cinematique\functions');

%% Interrupteurs
saveresults = 1;
test        = 0;
anato       = 1;
model       = 2.1;

%% Nom des sujets
Alias.sujet = sujets_valides;

for isujet = length(Alias.sujet) : -1 : 1
    
    disp(['Traitement de ' cell2mat(Alias.sujet(isujet)) ' (' num2str(length(Alias.sujet) - isujet+1) ' sur ' num2str(length(Alias.sujet)) ')'])
    %% Chemin des fichiers
    % Dossier du sujet
    Path.DirModels  = ['\\10.89.24.15\f\Data\Shoulder\Lib\' Alias.sujet{isujet} 'd\Model_' num2str(round(model)) '\'];
    % Dossier du mod�le pour le sujet
    Path.pathModel  = [Path.DirModels 'Model.s2mMod'];
    % Dossier des data
    Path.importPath = ['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\' Alias.sujet{isujet} 'd\Trials\'];
    % Dossier d'exportation
    Path.exportPath = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\matrices\';
    % Noms des fichiers data
    Alias.Qnames    = dir([Path.importPath '*_MOD' num2str(model) '_*' 'r' '*.Q*']);
    
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
    [Alias.segmentMarkers, Alias.segmentDoF] = segment_RBDL(round(model));
    
    
   %% Anatomical position correction
   if anato == 1
       save_fig = 1;
       [q_correct] = anatomical_correction(Alias.sujet{isujet}, model, Alias.model, save_fig);
   elseif anato == 0
       q_correct = 0;
   end
   
    %% Obtenir les onset et offset de force
    load(['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\' Alias.sujet{isujet} 'd\forceindex\' Alias.sujet{isujet} '_forceindex'])
    
    for trial = length(Alias.Qnames) : -1 : 1
        %% Caract�ristique de l'essai
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
        
        %% Contribution des articulation � la hauteur
        % Initialisation des Q
        if length(fieldnames(Data(trial).Qdata)) == 3
            q1 = Data(trial).Qdata.Q2(:,round(Data(trial).start:Data(trial).end));
        elseif length(fieldnames(Data(trial).Qdata)) == 1
            q1 = Data(trial).Qdata.Q1(:,round(Data(trial).start:Data(trial).end));
        end
        
        %% Filtre passe-bas 25Hz
        q1 = transpose(lpfilter(q1', 15, 100));
        
        %% Articulation 1 : Poignet + coude
        % Coordonn�es des marqueurs dans le rep�re global
        T = S2M_rbdl('Tags', Alias.model, q1);
        
        % Marqueurs du segment en cours ('3' correspond � Z car on s'int�resse � la hauteur)
        H1 = squeeze(T(3,39,:));
        
        % Moment de prise et l�ch� de caisse
        hstart    = H1(1);
        hend      = H1(end);
        h         = [hstart hend];
        
        % Pour diff�rencier entre essai de mont�e et descente
        bas       = min(h);
        haut      = max(h);
        
        % normalisation
        H1 = (H1 - bas) / (haut - bas)*100;
        
        % Blocage des q du segment
        q1(Alias.segmentDoF.handelbow,:) = repmat(q_correct(Alias.segmentDoF.handelbow), 1, length(q1));
        
        % Redefinition des marqueurs avec les q bloqu�s
        T = S2M_rbdl('Tags', Alias.model, q1);
        
        % Marqueurs du segment en cours avec q bloqu�s
        H2 = squeeze(T(3,39,:));
        
        % normalisation avec 100 = max de H1
        H2 = (H2 - bas) / (haut - bas)*100;
        
        % Delta entre les deux matrices de marqueurs en Z
        Data(trial).deltahand  = H1 - H2;
        
        %% Articulation 2 : GH
        % Blocage des q du segment
        q1(Alias.segmentDoF.GH,:) = repmat(q_correct(Alias.segmentDoF.GH), 1, length(q1));
        
        % Redefinition des marqueurs avec les q bloqu�s
        T = S2M_rbdl('Tags', Alias.model,q1);
        
        % Marqueurs du segment en cours avec q bloqu�s
        H3 = squeeze(T(3,39,:));
        
        % normalisation avec 100 = max de H1
        H3 = (H3 - bas) / (haut - bas)*100;
        
        % Delta entre les deux matrices de marqueurs en Z
        Data(trial).deltaGH  = H2 - H3;
        
        %% Articulation 3 : GH
        % Blocage des q du segment
        q1(Alias.segmentDoF.SCAC,:) = repmat(q_correct(Alias.segmentDoF.SCAC), 1, length(q1));
        
        % Redefinition des marqueurs avec les q bloqu�s
        T = S2M_rbdl('Tags', Alias.model, q1);
        
        % Marqueurs du segment en cours avec q bloqu�s
        H4 = squeeze(T(3,39,:));
        
        % normalisation avec 100 = max de H1
        H4 = (H4 - bas) / (haut - bas)*100;
        
        % Delta entre les deux matrices de marqueurs en Z
        Data(trial).deltaSCAC  = H3 - H4;
        
        %% Articulation 4 : Reste du corps (pelvis + thorax)
        % Blocage des q du segment
        q1(Alias.segmentDoF.RoB,:) = repmat(q_correct(Alias.segmentDoF.RoB), 1, length(q1));
        
        % Redefinition des marqueurs avec les q bloqu�s
        T = S2M_rbdl('Tags', Alias.model, q1);
        
        % Marqueurs du segment en cours avec q bloqu�s
        H5 = squeeze(T(3,39,:));
        
        % normalisation avec 100 = max de H1
        H5 = (H5 - bas) / (haut - bas)*100;
        
        % Delta entre les deux matrices de marqueurs en Z
        Data(trial).deltaRoB  = H4 - H5;
        
        
    end
    
    %% Condition de l'essai
    [Data]    = getcondition(Data);
    [~,index] = sortrows([Data.condition].'); Data = Data(index); clear index
    
    S2M_rbdl('delete', Alias.model);
    
    %% Sauvegarde de la matrice
    if saveresults == 1
        % hauteur
        temp = rmfield(Data,'Qdata');
        save([Path.exportPath 'hauteur\' Alias.sujet{1,isujet} '.mat'],'temp')
        clearvars temp 
        % cin�matique
        temp = rmfield(Data, {'deltahand', 'deltaGH', 'deltaSCAC', 'deltaRoB'});
        save([Path.exportPath 'cinematique\' Alias.sujet{1,isujet} '.mat'],'temp')
        clearvars temp
    end
    
    clearvars data Data forceindex logical_cells H1 H2 H3 H4 H5 q1 T
end