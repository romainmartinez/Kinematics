%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ____                       _         __  __            _   _                  %
% |  _ \ ___  _ __ ___   __ _(_)_ __   |  \/  | __ _ _ __| |_(_)_ __   ___ ____  %
% | |_) / _ \| '_ ` _ \ / _` | | '_ \  | |\/| |/ _` | '__| __| | '_ \ / _ \_  /  %
% |  _ < (_) | | | | | | (_| | | | | | | |  | | (_| | |  | |_| | | | |  __// /   %
% |_| \_\___/|_| |_| |_|\__,_|_|_| |_| |_|  |_|\__,_|_|   \__|_|_| |_|\___/___|  %
%                                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            clc; clear; close all 
%% Informations sur le sujet et l'essai                            
Alias.sujet = input('Enter subjet name : ','s'); ;
%% Chemin de la librairie et des fichiers
    % Librairie S2M
loadS2MLib;
    % Chemin des fonctions perso
addpath(genpath('\\10.89.24.15\e\Projet_Romain\Codes\Functions_Matlab'));
    % Dossier du sujet
Path.DirModels  = ['\\10.89.24.15\f\Data\Shoulder\Lib\IRSST_' Alias.sujet 'd\Model_2\'] ;
    % Dossier du mod�le pour le sujet
Path.pathModel  = [Path.DirModels 'Model.s2mMod'] ;
    % Dossier des data
Path.importPath = ['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\IRSST_' Alias.sujet 'd\Trials\'] ;
    % Noms des fichiers data
Alias.Qnames    = dir([Path.importPath '*.Q2']) ;

%% Ouverture et information du mod�le
    % Ouverture du mod�le
Stuff.model    = S2M_rbdl('new',Path.pathModel) ;
    % Noms et nombre de DoF
Alias.nameDof  = S2M_rbdl('nameDof', Stuff.model) ;     
Alias.nDof     = S2M_rbdl('nDof', Stuff.model) ; 
    % Noms et nombre de marqueurs
Alias.nameTags = S2M_rbdl('nameTags', Stuff.model) ;     
Alias.nTags    = S2M_rbdl('nTags', Stuff.model) ; 
    % Nom des segments
Alias.nameBody = S2M_rbdl('nameBody', Stuff.model) ;
    % identification des marqueurs correspondant � chaque segement
        % handelbow
        Alias.segmentMarkers.handelbow = [32:43];
        % GH
        Alias.segmentMarkers.GH        = [25:31];
        % SCAC
        Alias.segmentMarkers.SCAC      = [11:24];
        % RoB
        Alias.segmentMarkers.RoB       = [1:10];
    % identification des DoF correspondant � chaque segement
        % handelbow
        Alias.segmentDoF.handelbow = [25:28];
        % GH
        Alias.segmentDoF.GH        = [19:24];
        % SCAC
        Alias.segmentDoF.SCAC      = [13:18];
        % RoB
        Alias.segmentDoF.RoB       = [1:12];    

for trial = 1 : 3%length(Alias.Qnames)
    % Importation des Q,QDOT,QDDOT
Data(trial).Qdata     = importdata([Path.importPath Alias.Qnames(trial).name]) ;
    % Noms des essais
Data(trial).trialname = Alias.Qnames(trial).name(5:11) ;
%% Contribution des articulation � la hauteur
    % Initialisation des Q
Data(trial).q1 = Data(trial).Qdata.Q2;
%% Articulation 1 : Poignet + coude
    % Coordonn�es des marqueurs dans le rep�re global
Data(trial).T = S2M_rbdl('Tags', Stuff.model, Data(trial).q1) ;
            % Marqueurs du segment en cours ('3' correspond � Z car on s'int�resse � la hauteur)
        Data(trial).H1 = squeeze(Data(trial).T(3,:,:));
    % Blocage des q du segment
Data(trial).q1(Alias.segmentDoF.handelbow(1):Alias.segmentDoF.handelbow(end),:) = 0;
    % Redefinition des marqueurs avec les q bloqu�s
Data(trial).T = S2M_rbdl('Tags', Stuff.model, Data(trial).q1) ;
            % Marqueurs du segment en cours avec q bloqu�s
        Data(trial).H2 = squeeze(Data(trial).T(3,:,:));
    % Delta entre les deux matrices de marqueurs en Z
Data(trial).deltahand  = Data(trial).H1-Data(trial).H2;

%% Articulation 2 : GH
    % Blocage des q du segment
Data(trial).q1(Alias.segmentDoF.GH(1):Alias.segmentDoF.GH(end),:) = 0;
    % Redefinition des marqueurs avec les q bloqu�s
Data(trial).T = S2M_rbdl('Tags', Stuff.model, Data(trial).q1) ;
            % Marqueurs du segment en cours avec q bloqu�s
        Data(trial).H3 = squeeze(Data(trial).T(3,:,:));
    % Delta entre les deux matrices de marqueurs en Z
Data(trial).deltaGH  = Data(trial).H2-Data(trial).H3;

%% Articulation 3 : GH
    % Blocage des q du segment
Data(trial).q1(Alias.segmentDoF.SCAC(1):Alias.segmentDoF.SCAC(end),:) = 0;
    % Redefinition des marqueurs avec les q bloqu�s
Data(trial).T = S2M_rbdl('Tags', Stuff.model, Data(trial).q1) ;
            % Marqueurs du segment en cours avec q bloqu�s
        Data(trial).H4 = squeeze(Data(trial).T(3,:,:));
    % Delta entre les deux matrices de marqueurs en Z
Data(trial).deltaSCAC  = Data(trial).H3-Data(trial).H4;

%% Articulation 4 : Reste du corps (pelvis + thorax)
    % Blocage des q du segment
Data(trial).q1(Alias.segmentDoF.RoB(1):Alias.segmentDoF.RoB(end),:) = 0;
    % Redefinition des marqueurs avec les q bloqu�s
Data(trial).T = S2M_rbdl('Tags', Stuff.model, Data(trial).q1) ;
            % Marqueurs du segment en cours avec q bloqu�s
        Data(trial).H5 = squeeze(Data(trial).T(3,:,:));
    % Delta entre les deux matrices de marqueurs en Z
Data(trial).deltaRoB  = Data(trial).H4-Data(trial).H5;

end

%% Condition de l'essai
[Data] = getcondition(Data);