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
addpath(genpath('\\10.89.24.15\Projet_Romain\Codes\Functions_Matlab'))
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
    % Tranposition des matrices de Q,QDOT,QDDOT
Data(trial).Qdata.Q2 = transpose(Data(trial).Qdata.Q2) ;
Data(trial).Qdata.QDDOT2 = transpose(Data(trial).Qdata.Q2) ;
Data(trial).Qdata.QDOT2 = transpose(Data(trial).Qdata.Q2) ;
    % Noms des essais
Data(trial).trialname = Alias.Qnames(trial).name(5:11) ;
    % Interpolation (juste pour pouvoir visualiser)
Stuff.oldframe = (1:size(Data(trial).Qdata.Q2,1))./size(Data(trial).Qdata.Q2,1)*100;
Stuff.newframe = linspace(Stuff.oldframe(1,1),100,100);
Data(trial).Qinterp = interp1(Stuff.oldframe,Data(trial).Qdata.Q2,Stuff.newframe,'spline');
end

%% Condition de l'essai
[Data] = getcondition(Data);

%% GUI de vérification
GUI_reconstruction
    % navigation entre hauteur : bouton next & previous
    % navigation entre les segments : liste déroulante
    
%% Plot 
    % Couleur
[colors] = distinguishable_colors(9);
    % Sélection du segment
Segment = 'Pelvis';
    % Sélection de la hauteur et sélection essai
hauteur = 5;    
indexh = find([Data.hauteur] == hauteur);
    % Trouver les q correspondant au segment (colonne de la matrice Q)
indexq = strfind(Alias.nameDof,Segment);
indexq = find(~cellfun(@isempty,indexq));

    % Boucle pour ploter les Q de ce DoF et cette hauteur
for s = 1 : length(indexq)    
    for i = 1 : length(indexh)
        subaxis(3,2,s,'Margin',0.03);
        hold on
        plot(Data(indexh(i)).Qinterp(:,indexq(s)),...
             'LineWidth',2,...
             'Color',[colors(i,:)]);
    end
    title([Alias.nameDof{indexq(s)} '(Q col ' num2str(indexq(s)) ')'])
    legend(Data(indexh).trialname, 'location', 'SouthEast')
    hold off;
end