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
            addpath(genpath('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'));
    end
    % Dossier du sujet
Path.DirModels  = ['\\10.89.24.15\f\Data\Shoulder\Lib\IRSST_' Alias.sujet 'd\Model_2\'] ;
    % Dossier du modèle pour le sujet
Path.pathModel  = [Path.DirModels 'Model.s2mMod'] ;
    % Dossier importation data
Path.importPath = ['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\IRSST_' Alias.sujet 'd\Trials\'] ;
    % Noms des fichiers data
Alias.Qnames    = dir([Path.importPath '*.Q2']) ;
    % Dossier exportation data   
Path.exportPath = ['\\10.89.24.15\f\Data\Shoulder\RAW\IRSST_' Alias.sujet 'd\OpenSim\'];
mkdir(Path.exportPath)    

%% Ouverture et information du modèle
    % Ouverture du modèle
Stuff.model     = S2M_rbdl('new',Path.pathModel) ;
    % Noms et nombre de DoF
Alias.nameDof   = S2M_rbdl('nameDof', Stuff.model) ;     
Alias.nDof      = S2M_rbdl('nDof', Stuff.model) ; 
    % Noms et nombre de marqueurs
Alias.nameTags  = S2M_rbdl('nameTags', Stuff.model) ;     
Alias.nTags     = S2M_rbdl('nTags', Stuff.model) ; 
    % Nom des segments
Alias.nameBody  = S2M_rbdl('nameBody', Stuff.model) ; 
    % Fréquence d'acquisition
Alias.frequency = 100;    

for trial = 1 : length(Alias.Qnames)
%% Importation des data    
    % Importation des Q,QDOT,QDDOT
Data(trial).Qdata     = importdata([Path.importPath Alias.Qnames(trial).name]) ;
    % Importation des marqueurs
Data(trial).T         = S2M_rbdl('Tags', Stuff.model, Data(trial).Qdata.Q2);    % Noms des essais
    % Noms des essais
    switch lower(Alias.Qnames(trial).name(1:4))
        case 'irss'
Data(trial).trialname = ['SCoRE' Alias.Qnames(trial).name(12)] ;
        case lower(Alias.sujet)
Data(trial).trialname = Alias.Qnames(trial).name(5:11) ;
    end
    
%% Variables pour la création de fichiers OpenSim
    % vecteur temporel (s)
Data(trial).time      = (0:size(Data(trial).Qdata.Q2,2)-1)/Alias.frequency;
    % # frame
Data(trial).frame = [1:length(Data(trial).T)];    
    % dimensions
[~,Data(trial).nb_mark,Data(trial).nb_Frame] = size(Data(trial).T);
    
%% Creation du fichier .trc (le fichier anatomique ou mouvement si on veut faire IK)
    % Headers (fichier)
confTrc.header1 = {'PathFileType' , '4' , '(X/Y/Z)', [Data(trial).trialname '.trc']} ;
    % Headers (Catégorie)
confTrc.header2 = {'DataRate' , 'CameraRate' , 'NumFrames' , 'NumMarkers' , 'Units' , 'OrigDataRate' , 'OrigDataStartFrame' , 'OrigNumFrames'} ;
    % Headers (Configuration)
confTrc.header3 = {num2str(Alias.frequency), num2str(Alias.frequency), num2str(Data(trial).nb_Frame),...
                   num2str(Data(trial).nb_mark), 'm' , num2str(Alias.frequency) ,...
                   '0', num2str((Data(trial).nb_Frame-1)/Alias.frequency)} ;
    % Headers (Marqueurs + temps + frame);
confTrc.header4 = {'Frame#','s'};
for i=1:Data(trial).nb_mark
    confTrc.header4 = [confTrc.header4 Alias.nameTags(i) ' ' ' '];
end
    % Headers (Marqueurs + temps + frame)
confTrc.header5 = {'Frame#','s'} ;
for i=1:Data(trial).nb_mark
    confTrc.header5 = [confTrc.header5 sprintf('x%d',i) sprintf('y%d',i) sprintf('z%d',i)];
end
    % Matrice pour écriture fichier .trc    
Data(trial).trcmat    = [Data(trial).frame ; Data(trial).time ; reshape(Data(trial).T,[length(Alias.nameTags)*3 length(Data(trial).T)])]'; 
    % fonction permettant de générer le .trc
GenerateOpenSimTrcFile(Path.exportPath, Data(trial).trialname,confTrc,Data(trial).trcmat);
    % Nettoyage Workspace
clearvars confTrc
end

    % Condition des essais (hauteur et poids)
[Data] = getcondition(Data);
