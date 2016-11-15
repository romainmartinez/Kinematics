%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ____                       _         __  __            _   _                  %
% |  _ \ ___  _ __ ___   __ _(_)_ __   |  \/  | __ _ _ __| |_(_)_ __   ___ ____  %
% | |_) / _ \| '_ ` _ \ / _` | | '_ \  | |\/| |/ _` | '__| __| | '_ \ / _ \_  /  %
% |  _ < (_) | | | | | | (_| | | | | | | |  | | (_| | |  | |_| | | | |  __// /   %
% |_| \_\___/|_| |_| |_|\__,_|_|_| |_| |_|  |_|\__,_|_|   \__|_|_| |_|\___/___|  %
%                                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            clc; clear; close all; tic;
%% Chargement des fonctions
    if isempty(strfind(path, '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'))
        % Librairie S2M
            loadS2MLib;
        % Fonctions perso
            addpath(genpath('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'));
    end
%% Nom du sujet
% Alias.sujet = input('Enter subject name : ','s');
Alias.sujet = 'davo';                    
%% Chemin des fichiers
    % Dossier du sujet
Path.DirModels  = ['\\10.89.24.15\f\Data\Shoulder\Lib\IRSST_' Alias.sujet 'd\Model_2\'];
    % Dossier du mod�le pour le sujet
Path.pathModel  = [Path.DirModels 'Model.s2mMod'];
    % Dossier des data
Path.importPath = ['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\IRSST_' Alias.sujet 'd\Trials\'];
    % Noms des fichiers data
Alias.Qnames    = dir([Path.importPath '*.Q2']);

%% Ouverture et information du mod�le    
    % Ouverture du mod�le
Stuff.model    = S2M_rbdl('new',Path.pathModel);
    % Noms et nombre de DoF
Alias.nameDof  = S2M_rbdl('nameDof', Stuff.model);     
Alias.nDof     = S2M_rbdl('nDof', Stuff.model); 
    % Noms et nombre de marqueurs
Alias.nameTags = S2M_rbdl('nameTags', Stuff.model);     
Alias.nTags    = S2M_rbdl('nTags', Stuff.model); 
    % Nom des segments
Alias.nameBody = S2M_rbdl('nameBody', Stuff.model);
    % identification des marqueurs correspondant � chaque segement
        % handelbow
        Alias.segmentMarkers.handelbow = 32:43;
        % GH
        Alias.segmentMarkers.GH        = 25:31;
        % SCAC
        Alias.segmentMarkers.SCAC      = 11:24;
        % RoB
        Alias.segmentMarkers.RoB       = 1:10;
    % identification des DoF correspondant � chaque segement
        % handelbow
        Alias.segmentDoF.handelbow     = 25:28;
        % GH
        Alias.segmentDoF.GH            = 19:24;
        % SCAC
        Alias.segmentDoF.SCAC          = 13:18;
        % RoB
        Alias.segmentDoF.RoB           = 1:12;    

for trial = 1 : 3 %length(Alias.Qnames)
%% Importation des Q,QDOT,QDDOT
Data(trial).Qdata     = importdata([Path.importPath Alias.Qnames(trial).name]);
    % Noms des essais
Data(trial).trialname = Alias.Qnames(trial).name(5:11);
%% Contribution des articulation � la hauteur
    % Initialisation des Q
q1 = Data(trial).Qdata.Q2;
%% Articulation 1 : Poignet + coude
	% Coordonn�es des marqueurs dans le rep�re global
T = S2M_rbdl('Tags', Stuff.model, q1);
        % Marqueurs du segment en cours ('3' correspond � Z car on s'int�resse � la hauteur)
    H1 = squeeze(T(3,39,:));
    % Blocage des q du segment
q1(Alias.segmentDoF.handelbow(1):Alias.segmentDoF.handelbow(end),:) = 0;
    % Redefinition des marqueurs avec les q bloqu�s
T = S2M_rbdl('Tags', Stuff.model, q1);
        % Marqueurs du segment en cours avec q bloqu�s
    H2 = squeeze(T(3,39,:));
    % Delta entre les deux matrices de marqueurs en Z
Data(trial).deltahand  = H1-H2;

%% Articulation 2 : GH
    % Blocage des q du segment
q1(Alias.segmentDoF.GH(1):Alias.segmentDoF.GH(end),:) = 0;
    % Redefinition des marqueurs avec les q bloqu�s
T = S2M_rbdl('Tags', Stuff.model,q1);
        % Marqueurs du segment en cours avec q bloqu�s
    H3 = squeeze(T(3,39,:));
    % Delta entre les deux matrices de marqueurs en Z
Data(trial).deltaGH  = H2-H3;

%% Articulation 3 : GH
    % Blocage des q du segment
q1(Alias.segmentDoF.SCAC(1):Alias.segmentDoF.SCAC(end),:) = 0;
    % Redefinition des marqueurs avec les q bloqu�s
T = S2M_rbdl('Tags', Stuff.model, q1);
        % Marqueurs du segment en cours avec q bloqu�s
    H4 = squeeze(T(3,39,:));
    % Delta entre les deux matrices de marqueurs en Z
Data(trial).deltaSCAC  = H3-H4;

%% Articulation 4 : Reste du corps (pelvis + thorax)
    % Blocage des q du segment
q1(Alias.segmentDoF.RoB(1):Alias.segmentDoF.RoB(end),:) = 0;
    % Redefinition des marqueurs avec les q bloqu�s
T = S2M_rbdl('Tags', Stuff.model, q1);
            % Marqueurs du segment en cours avec q bloqu�s
       H5 = squeeze(T(3,39,:));
    % Delta entre les deux matrices de marqueurs en Z
Data(trial).deltaRoB  = H4-H5;
    % Nettoyage du workspace
% clearvars H1 H2 H3 H4 H5 q1 T
end

%% Condition de l'essai
[Data] = getcondition(Data);

%% D�terminer la phase du mouvement
    % Obtenir les onset et offset de force
[Force] = getforcedata(Alias.sujet);
    % Obtenir la vitesse verticale du marqueur WRIST

T = S2M_rbdl('Tags', Stuff.model, Data(trial).Qdata.Q2);
TJ = S2M_rbdl('TagsJacobian', Stuff.model, Data(trial).Qdata.Q2);
xpoint = TJ*Data(trial).Qdata.QDOT2;


plot(xpoint(125,:)); hold on
vline([Force(trial).onsetensec*100 Force(trial).offsetensec*100],{'g','r'},{'D�but','Fin'})



    % d�but essai : time = 0                                OK
    % arrach� : force start                                 OK
    % transfert : marqueur main avec vitesse verticale
    % d�p�t : fin vitesse verticale
    % fin d�p�t : force end                                 OK
    
[Force] = getforcedata(Alias.sujet)
%% Plot
subplot(1,2,1)
plot([H1 H2 H3 H4 H5])
legend('normal','without hand','without GH','without SCAC','without RoB')
subplot(1,2,2)
plot(Data(1).deltahand') ; hold on
plot(Data(1).deltaGH')
plot(Data(1).deltaSCAC')
plot(Data(1).deltaRoB')
legend('contrib hand','contrib GH','contrib SCAC','contrib RoB')

    hauteur= Data(3).deltahand+Data(3).deltaGH+Data(3).deltaSCAC+Data(3).deltaRoB

toc;