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

%% Importation des data
for trial = 1 : 3%length(Alias.Qnames)
    % Importation des Q,QDOT,QDDOT
Data(trial).Qdata     = importdata([Path.importPath Alias.Qnames(trial).name]) ;
    % Noms des essais
Data(trial).trialname = Alias.Qnames(trial).name(5:11) ;
    % Interpolation (juste pour pouvoir visualiser)
% Data(trial).Qdata.Q2  = transpose(Data(trial).Qdata.Q2);
Stuff.oldframe        = (1:size(transpose(Data(trial).Qdata.Q2),1))./size(transpose(Data(trial).Qdata.Q2),1)*100;
Stuff.newframe        = linspace(Stuff.oldframe(1,1),100,100);
Data(trial).Qinterp   = interp1(Stuff.oldframe,transpose(Data(trial).Qdata.Q2),Stuff.newframe,'spline');
clearvars Stuff.oldframe Stuff.newframe
end

%% Condition de l'essai
[Data] = getcondition(Data);

%%  Code Mickael (Optimiser) %%%%%%%%%%%%%
    % Initialisation des Q
i = 1;
Data(i).q1 = Data(i).Qdata.Q2;
%% Articulation 1 : Poignet + coude
    % Coordonn�es des marqueurs dans le rep�re global
Data(i).T           = S2M_rbdl('Tags', Stuff.model, Data(i).q1) ;

    % D�finition de la hauteur pour les marqueurs du segment en cours
    % le '3' correspond au Z car on s'int�resse � la hauteur
Data(i).H1          = squeeze(Data(i).T(3,Alias.segmentMarkers.handelbow(1):Alias.segmentMarkers.handelbow(end),:));

Data(i).q1(:,Alias.segmentDoF.handelbow(1):Alias.segmentDoF.handelbow(end)) = 0;

Data(i).T           = S2M_rbdl('Tags', Stuff.model, q1) ;

Data(i).H2          = squeeze(T(3,32:43,:));

xi          = H2-H1;
