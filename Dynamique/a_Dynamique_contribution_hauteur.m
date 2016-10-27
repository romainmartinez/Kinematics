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
Alias.sujet = 'dapo';                    
%% Chemin des fichiers
    % Dossier du sujet
Path.DirModels  = ['\\10.89.24.15\f\Data\Shoulder\Lib\IRSST_' Alias.sujet 'd\Model_2\'];
    % Dossier du modèle pour le sujet
Path.pathModel  = [Path.DirModels 'Model.s2mMod'];
    % Dossier des data
Path.importPath = ['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\IRSST_' Alias.sujet 'd\Trials\'];
    % Noms des fichiers data
Alias.Qnames    = dir([Path.importPath '*.Q2']);

%% Ouverture et information du modèle    
    % Ouverture du modèle
Stuff.model    = S2M_rbdl('new',Path.pathModel);
    % Noms et nombre de DoF
Alias.nameDof  = S2M_rbdl('nameDof', Stuff.model);     
Alias.nDof     = S2M_rbdl('nDof', Stuff.model); 
    % Noms et nombre de marqueurs
Alias.nameTags = S2M_rbdl('nameTags', Stuff.model);     
Alias.nTags    = S2M_rbdl('nTags', Stuff.model); 
    % Nom des segments
Alias.nameBody = S2M_rbdl('nameBody', Stuff.model);
    % identification des marqueurs correspondant à chaque segement
        % handelbow
        Alias.segmentMarkers.handelbow = 32:43;
        % GH
        Alias.segmentMarkers.GH        = 25:31;
        % SCAC
        Alias.segmentMarkers.SCAC      = 11:24;
        % RoB
        Alias.segmentMarkers.RoB       = 1:10;
    % identification des DoF correspondant à chaque segement
        % handelbow
        Alias.segmentDoF.handelbow = 25:28;
        % GH
        Alias.segmentDoF.GH        = 19:24;
        % SCAC
        Alias.segmentDoF.SCAC      = 13:18;
        % RoB
        Alias.segmentDoF.RoB       = 1:12;    

for trial = 1 : 3 %length(Alias.Qnames)
%% Importation des Q,QDOT,QDDOT
Data(trial).Qdata     = importdata([Path.importPath Alias.Qnames(trial).name]);
    % Noms des essais
Data(trial).trialname = Alias.Qnames(trial).name(5:11);
%% Contribution des articulation à la hauteur
    % Initialisation des Q
q1 = Data(trial).Qdata.Q2;
%% Articulation 1 : Poignet + coude
	% Coordonnées des marqueurs dans le repère global
T = S2M_rbdl('Tags', Stuff.model, q1);
        % Marqueurs du segment en cours ('3' correspond à Z car on s'intéresse à la hauteur)
    H1 = squeeze(T(3,39,:));
    % Blocage des q du segment
q1(Alias.segmentDoF.handelbow(1):Alias.segmentDoF.handelbow(end),:) = 0;
    % Redefinition des marqueurs avec les q bloqués
T = S2M_rbdl('Tags', Stuff.model, q1);
        % Marqueurs du segment en cours avec q bloqués
    H2 = squeeze(T(3,39,:));
    % Delta entre les deux matrices de marqueurs en Z
Data(trial).deltahand  = H1-H2;

%% Articulation 2 : GH
    % Blocage des q du segment
q1(Alias.segmentDoF.GH(1):Alias.segmentDoF.GH(end),:) = 0;
    % Redefinition des marqueurs avec les q bloqués
T = S2M_rbdl('Tags', Stuff.model,q1);
        % Marqueurs du segment en cours avec q bloqués
    H3 = squeeze(T(3,39,:));
    % Delta entre les deux matrices de marqueurs en Z
Data(trial).deltaGH  = H2-H3;

%% Articulation 3 : GH
    % Blocage des q du segment
q1(Alias.segmentDoF.SCAC(1):Alias.segmentDoF.SCAC(end),:) = 0;
    % Redefinition des marqueurs avec les q bloqués
T = S2M_rbdl('Tags', Stuff.model, q1);
        % Marqueurs du segment en cours avec q bloqués
    H4 = squeeze(T(3,39,:));
    % Delta entre les deux matrices de marqueurs en Z
Data(trial).deltaSCAC  = H3-H4;

%% Articulation 4 : Reste du corps (pelvis + thorax)
    % Blocage des q du segment
q1(Alias.segmentDoF.RoB(1):Alias.segmentDoF.RoB(end),:) = 0;
    % Redefinition des marqueurs avec les q bloqués
T = S2M_rbdl('Tags', Stuff.model, q1);
            % Marqueurs du segment en cours avec q bloqués
       H5 = squeeze(T(3,39,:));
    % Delta entre les deux matrices de marqueurs en Z
Data(trial).deltaRoB  = H4-H5;
    % Nettoyage du workspace
% clearvars H1 H2 H3 H4 H5 q1 T
end

%% Condition de l'essai
[Data] = getcondition(Data);

%% Déterminer la phase du mouvement
    % Obtenir les onset et offset de force
[Force] = getforcedata(Alias.sujet)

T = S2M_rbdl('Tags', Stuff.model, Data(trial).Qdata.Q2);
main = squeeze(T(1:3,39,:));
mainpoint = diff(main)
plot(main','LineWidth',2)
legend('x','y','z')

    % début essai : time = 0
    % arraché : force start OK
    % transfert : marqueur main avec vitesse verticale
    % dépôt : fin vitesse verticale
    % fin dépôt : force end OK
    
[Force] = getforcedata(Alias.sujet)
%% Plot
% figure;
% plot([H1 H2 H3 H4 H5])
% legend('normal','without hand','without GH','without SCAC','without RoB')
% figure;
% plot(Data(3).deltahand') ; hold on
% plot(Data(3).deltaGH')
% plot(Data(3).deltaSCAC')
% plot(Data(3).deltaRoB')
% legend('contrib hand','contrib GH','contrib SCAC','contrib RoB')

toc;