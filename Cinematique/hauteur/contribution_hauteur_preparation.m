%   Description:
%       contribution_hauteur_preparation is used to compute the contribution of each
%       articulation to the height
%   Output:
%       contribution_hauteur_preparation gives matrix for input in SPM1D and GRAMM
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
cd('C:\Users\marti\Documents\Codes\Kinematics\Cinematique\functions');

%% Interrupteurs
saveresults = 0;
test        = 0;
model       = 3;

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
    Path.exportPath = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_hauteur\elaboratedData_mat\';
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
    
    %% Obtenir les onset et offset de force
    load(['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\' Alias.sujet{isujet} 'd\forceindex\' Alias.sujet{isujet} '_forceindex'])
    
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
        
        %% Importation des Q,QDOT,QDDOT
        Data(trial).Qdata = load([Path.importPath Alias.Qnames(trial).name], '-mat');
        
        %% Contribution des articulation à la hauteur
        % Initialisation des Q
        if length(fieldnames(Data(trial).Qdata)) == 3
            q1 = Data(trial).Qdata.Q2;
        elseif length(fieldnames(Data(trial).Qdata)) == 1
            q1 = Data(trial).Qdata.Q1;
        end
        
        %% Filtre passe-bas 25Hz
        q1 = transpose(lpfilter(q1', 15, 100));
        
        %% Articulation 1 : Poignet + coude
        % Coordonnées des marqueurs dans le repère global
        T = S2M_rbdl('Tags', Alias.model, q1);
        
        % Marqueurs du segment en cours ('3' correspond à Z car on s'intéresse à la hauteur)
        Data(trial).H1 = squeeze(T(3,39,:));
        
        % Moment de prise et lâché de caisse
        hstart    = Data(trial).H1(round(Data(trial).start));
        hend      = Data(trial).H1(round(Data(trial).end));
        h         = [hstart hend];
        
        % Pour différencier entre essai de montée et descente
        bas       = min(h);
        haut      = max(h);
        
        % normalisation
        Data(trial).H1 = (Data(trial).H1 - bas) / (haut - bas)*100;
        
        % Blocage des q du segment
        q1(Alias.segmentDoF.handelbow,:) = 0;
        
        % Redefinition des marqueurs avec les q bloqués
        T = S2M_rbdl('Tags', Alias.model, q1);
        
        % Marqueurs du segment en cours avec q bloqués
        Data(trial).H2 = squeeze(T(3,39,:));
        
        % normalisation avec 100 = max de H1
        Data(trial).H2 = (Data(trial).H2 - bas) / (haut - bas)*100;
        
        % Delta entre les deux matrices de marqueurs en Z
        Data(trial).deltahand  = Data(trial).H1 - Data(trial).H2;
        
        %% Articulation 2 : GH
        % Blocage des q du segment
        q1(Alias.segmentDoF.GH,:) = 0;
        
        % Redefinition des marqueurs avec les q bloqués
        T = S2M_rbdl('Tags', Alias.model,q1);
        
        % Marqueurs du segment en cours avec q bloqués
        Data(trial).H3 = squeeze(T(3,39,:));
        
        % normalisation avec 100 = max de H1
        Data(trial).H3 = (Data(trial).H3 - bas) / (haut - bas)*100;
        
        % Delta entre les deux matrices de marqueurs en Z
        Data(trial).deltaGH  = Data(trial).H2 - Data(trial).H3;
        
        %% Articulation 3 : GH
        % Blocage des q du segment
        q1(Alias.segmentDoF.SCAC,:) = 0;
        
        % Redefinition des marqueurs avec les q bloqués
        T = S2M_rbdl('Tags', Alias.model, q1);
        
        % Marqueurs du segment en cours avec q bloqués
        Data(trial).H4 = squeeze(T(3,39,:));
        
        % normalisation avec 100 = max de H1
        Data(trial).H4 = (Data(trial).H4 - bas) / (haut - bas)*100;
        
        % Delta entre les deux matrices de marqueurs en Z
        Data(trial).deltaSCAC  = Data(trial).H3 - Data(trial).H4;
        
        %% Articulation 4 : Reste du corps (pelvis + thorax)
        % Blocage des q du segment
        q1(Alias.segmentDoF.RoB,:) = 0;
        
        % Redefinition des marqueurs avec les q bloqués
        T = S2M_rbdl('Tags', Alias.model, q1);
        
        % Marqueurs du segment en cours avec q bloqués
        Data(trial).H5 = squeeze(T(3,39,:));
        
        % normalisation avec 100 = max de H1
        Data(trial).H5 = (Data(trial).H5 - bas) / (haut - bas)*100;
        
        % Delta entre les deux matrices de marqueurs en Z
        Data(trial).deltaRoB  = Data(trial).H4 - Data(trial).H5;
        
        
    end
    
    %% Condition de l'essai
    [Data]    = getcondition(Data);
    [~,index] = sortrows([Data.condition].'); Data = Data(index); clear index
    
    S2M_rbdl('delete', Alias.model);
    
    %% Sauvegarde de la matrice
    if saveresults == 1
        data = rmfield(Data, 'Qdata');
        save([Path.exportPath Alias.sujet{1,isujet} '.mat'],'data')
    end
    clearvars data Data forceindex logical_cells
end

%% Zone de test 1
if test == 1
    
    essai = 1;
    
    q1 = Data(essai).Qdata.Q2;
    q1(Alias.segmentDoF.handelbow,:) = 0;
    q1(Alias.segmentDoF.GH,:)        = 0;
    q1(Alias.segmentDoF.SCAC,:)      = 0;
    q1(Alias.segmentDoF.RoB,:)       = 0;
    
    S2M_rbdl_AnimateModel(Alias.model, q1)
    
    %     for i = 1 : length(Data)
    %         figure('units','normalized','outerposition',[0 0 1 1])
    %         plot(Data(i).deltahand(round(Data(i).start):round(Data(i).end))) ; hold on
    %         plot(Data(i).deltaGH(  round(Data(i).start):round(Data(i).end)))
    %         plot(Data(i).deltaSCAC(round(Data(i).start):round(Data(i).end)))
    %         plot(Data(i).deltaRoB( round(Data(i).start):round(Data(i).end)))
    %         legend('contrib hand & elbow','contrib GH','contrib SCAC','contrib RoB')
    %     end
    %
    %     for i = 1 : length(Data)
    %         figure('units','normalized','outerposition',[0 0 1 1])
    %         plot(Data(i).H1(round(Data(i).start):round(Data(i).end))) ; hold on
    %         plot(Data(i).H2(round(Data(i).start):round(Data(i).end)))
    %         plot(Data(i).H3(round(Data(i).start):round(Data(i).end)))
    %         plot(Data(i).H4(round(Data(i).start):round(Data(i).end)))
    %         plot(Data(i).H5(round(Data(i).start):round(Data(i).end)))
    %         legend('normal','without hand & elbow','without GH','without SCAC','without RoB')
    %     end
    %
end
%% zone de test 2

% % Identifier début transfert et début dépôt avec position en Z
% framerate  = 100;
% index      = find(strcmp(Alias.nameTags, 'WRIST'));
% start      = round(Data(trial).start/20);
% finish     = round(Data(trial).end  /20);
% markerZ    = squeeze(T(3,index,:));
%
% etagere_depart   = max(markerZ(1:start));
% transfert = find(markerZ(start:end) > etagere_depart,1)+start;
% etagere_arrivee  = max(markerZ(start:end));
% depot     = find(markerZ(start:end) > etagere_arrivee-0.05*etagere_arrivee,1)+start
%
%
% plot(markerZ);
% vline([start finish],{'g','r'},{'Début','Fin'})
% vline(transfert)
% vline(depot)
%
%     % début essai : time = 0                                OK
%     %     arraché : force start                             OK
%     %   transfert : marqueur main avec position verticale   à vérifier
%     %       dépôt : marqueur main avec position verticale   à vérifier
%     %   fin dépôt : force end                               OK
%