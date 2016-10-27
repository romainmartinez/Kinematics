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
    % Chargement des fonctions
    if isempty(strfind(path, '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'))
        % Librairie S2M
            loadS2MLib;
        % Fonctions perso
            addpath(genpath('\\10.89.24.15\e\Projet_Romain\Codes\Functions_Matlab'));
    end
    % Dossier du sujet
Path.DirModels = ['\\10.89.24.15\f\Data\Shoulder\Lib\IRSST_' Alias.sujet 'd\Model_2\'] ;
    % Dossier du modèle pour le sujet
Path.pathModel = [Path.DirModels 'Model.s2mMod'] ;
    % Dossier des data
Path.importPath = ['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\IRSST_' Alias.sujet 'd\Trials\'] ;
    % Noms des fichiers data
Alias.Qnames = dir([Path.importPath '*.Q2']) ;

%% Ouverture et information du modèle
    % Ouverture du modèle
Stuff.model = S2M_rbdl('new',Path.pathModel) ;
    % Noms et nombre de DoF
Alias.nameDof = S2M_rbdl('nameDof', Stuff.model) ;     
Alias.nDof = S2M_rbdl('nDof', Stuff.model) ; 
    % Noms et nombre de marqueurs
Alias.nameTags = S2M_rbdl('nameTags', Stuff.model) ;     
Alias.nTags = S2M_rbdl('nTags', Stuff.model) ; 
    % Nom des segments
Alias.nameBody = S2M_rbdl('nameBody', Stuff.model) ; 
    

%% Importation des data
for trial = 1 : length(Alias.Qnames)
    % Importation des Q,QDOT,QDDOT
Data(trial).Qdata = importdata([Path.importPath Alias.Qnames(trial).name]) ;
    % Noms des essais
Data(trial).trialname = Alias.Qnames(trial).name(5:11) ;
    % Interpolation (juste pour pouvoir visualiser)
% Stuff.oldframe = (1:size(Data(trial).Qdata.Q2,1))./size(Data(trial).Qdata.Q2,1)*100;
% Stuff.newframe = linspace(Stuff.oldframe(1,1),100,100);
% Data(trial).Qinterp = interp1(Stuff.oldframe,Data(trial).Qdata.Q2,Stuff.newframe,'spline');
end

%% Condition de l'essai
[Data] = getcondition(Data);

%% Inverse Kinematics SEULKEMENT POUR UN ESSAI (boucle à faire)
    % Initialisation à 0.1 pour éviter blocage cardans
Qinit = repmat(0.1,28,1); 
    % Noms des marqueurs techniques
Alias.nameTechnicalTags = S2M_rbdl('nameTechnicalTags', Stuff.model);
    % Identification des marqueurs techniques
  for i = 1 : length(Alias.nameTechnicalTags)  
idx(i) = find(ismember(Alias.nameTags,Alias.nameTechnicalTags{i}));
  end
    % Trajectoires des marqueurs techniques
T = S2M_rbdl('Tags', Stuff.model, Data(1).Qdata.Q2);
    % Cinématique inverse
IK = S2M_rbdl('ik',Stuff.model, T(:,idx,:) ,Qinit);

%% Inverse Dynamics  
Dyn = S2M_rbdl('inverseDynamics', Stuff.model, Data(1).Qdata.Q2, Data(1).Qdata.QDOT2, Data(1).Qdata.QDDOT2, F);
    % rajouter les données de force (moments & forces dans le repère global)
Data = getforcedata(Alias)
    % Filtrer les données de force
    % Indiquer dans quel segment force plate (force plate 0 main)

    
    
    
%% Static Optimisation