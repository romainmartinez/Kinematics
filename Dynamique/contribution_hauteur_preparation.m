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
%   Date:    26-Nov-2016; Last revision: 29-Nov-2016
%_____________________________________________________________________________

clear all; close all; clc

%% Chargement des fonctions
if isempty(strfind(path, '\\10.89.24.15\e\Librairies\S2M_Lib\'))
    % Librairie S2M
    loadS2MLib;
end

%% Nom du sujet
Alias.sujet = myinput('Enter Subject Name');

%% Chemin des fichiers
% Dossier du sujet
Path.DirModels  = ['\\10.89.24.15\f\Data\Shoulder\Lib\IRSST_' Alias.sujet 'd\Model_2\'];
% Dossier du mod�le pour le sujet
Path.pathModel  = [Path.DirModels 'Model.s2mMod'];
% Dossier des data
Path.importPath = ['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\IRSST_' Alias.sujet 'd\Trials\'];
% Dossier d'exportation
Path.exportPath = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_hauteur\elaboratedData_mat\';
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
        
% Bar de progression
h = waitbar(0,'Please wait...');
steps = 54;

for trial = 1 : length(Alias.Qnames)
    if lower(Alias.Qnames(trial).name(1:4)) == lower(Alias.sujet)
        %% Importation des Q,QDOT,QDDOT
        Data(trial).Qdata     = load([Path.importPath Alias.Qnames(trial).name], '-mat');
        % Noms des essais
        Data(trial).trialname = Alias.Qnames(trial).name(5:11);
        
        %% Contribution des articulation � la hauteur
        % Initialisation des Q
        q1 = Data(trial).Qdata.Q2;
        
        %% Articulation 1 : Poignet + coude
        % Coordonn�es des marqueurs dans le rep�re global
        T = S2M_rbdl('Tags', Stuff.model, q1);
        % Marqueurs du segment en cours ('3' correspond � Z car on s'int�resse � la hauteur)
        Data(trial).H1 = squeeze(T(3,39,:));
        % Hauteur max
        hmax = max(Data(trial).H1);
        % normalisation avec 100 = max de H1
        Data(trial).H1 = (Data(trial).H1*100)/hmax;
        % Blocage des q du segment
        q1(Alias.segmentDoF.handelbow,:) = 0;
        % Redefinition des marqueurs avec les q bloqu�s
        T = S2M_rbdl('Tags', Stuff.model, q1);
        % Marqueurs du segment en cours avec q bloqu�s
        Data(trial).H2 = squeeze(T(3,39,:));
        % normalisation avec 100 = max de H1
        Data(trial).H2 = (Data(trial).H2*100)/hmax;
        % Delta entre les deux matrices de marqueurs en Z
        Data(trial).deltahand  = Data(trial).H1 - Data(trial).H2;
        
        %% Articulation 2 : GH
        % Blocage des q du segment
        q1(Alias.segmentDoF.GH,:) = 0;
        % Redefinition des marqueurs avec les q bloqu�s
        T = S2M_rbdl('Tags', Stuff.model,q1);
        % Marqueurs du segment en cours avec q bloqu�s
        Data(trial).H3 = squeeze(T(3,39,:));
        % normalisation avec 100 = max de H1
        Data(trial).H3 = (Data(trial).H3*100)/hmax;
        % Delta entre les deux matrices de marqueurs en Z
        Data(trial).deltaGH  = Data(trial).H2 - Data(trial).H3;
        
        %% Articulation 3 : GH
        % Blocage des q du segment
        q1(Alias.segmentDoF.SCAC,:) = 0;
        % Redefinition des marqueurs avec les q bloqu�s
        T = S2M_rbdl('Tags', Stuff.model, q1);
        % Marqueurs du segment en cours avec q bloqu�s
        Data(trial).H4 = squeeze(T(3,39,:));
        % normalisation avec 100 = max de H1
        Data(trial).H4 = (Data(trial).H4*100)/hmax;
        % Delta entre les deux matrices de marqueurs en Z
        Data(trial).deltaSCAC  = Data(trial).H3 - Data(trial).H4;
        
        %% Articulation 4 : Reste du corps (pelvis + thorax)
        % Blocage des q du segment
        q1(Alias.segmentDoF.RoB,:) = 0;
        % Redefinition des marqueurs avec les q bloqu�s
        T = S2M_rbdl('Tags', Stuff.model, q1);
        % Marqueurs du segment en cours avec q bloqu�s
        Data(trial).H5 = squeeze(T(3,39,:));
        % normalisation avec 100 = max de H1
        Data(trial).H5 = (Data(trial).H5*100)/hmax;
        % Delta entre les deux matrices de marqueurs en Z
        Data(trial).deltaRoB  = Data(trial).H4 - Data(trial).H5;
        
        waitbar(trial / steps);
    end
end
close(h)

%% Condition de l'essai
[Data]    = getcondition(Data);
[~,index] = sortrows([Data.condition].'); Data = Data(index); clear index

%% D�terminer les phases du mouvement
% Obtenir les onset et offset de force
[forceindex] = getforcedata(Alias.sujet);

% Identifier les onset et offset des data d�j� load�es et d�clarer le sexe
for i = 1 : length(Data)
    cellfind      = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
    logical_cells = cellfun(cellfind(Data(i).trialname),forceindex);
    [row,~]       = find(logical_cells == 1);
    Data(i).start = forceindex{row,1};
    Data(i).end   = forceindex{row,2};
    
    % sexe
    if length(Data) == 54
        Data(i).sexe = 'H';
    elseif length(Data) == 36
        Data(i).sexe = 'F';
    end
end
clearvars forceindex logical_cells row h cellfind

%% Sauvegarde de la matrice
% data = rmfield(Data, 'Qdata');
% save([Path.exportPath Alias.sujet '.mat'],'data')
%% Zone de test

% % Identifier d�but transfert et d�but d�p�t avec position en Z
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
% vline([start finish],{'g','r'},{'D�but','Fin'})
% vline(transfert)
% vline(depot)
% 
%     % d�but essai : time = 0                                OK
%     %     arrach� : force start                             OK
%     %   transfert : marqueur main avec position verticale   � v�rifier
%     %       d�p�t : marqueur main avec position verticale   � v�rifier
%     %   fin d�p�t : force end                               OK
% 
%% Plot
% trial = 30;
% subplot(1,2,1)
% plot([Data(trial).H1 Data(trial).H2 Data(trial).H3 Data(trial).H4 Data(trial).H5])
% vline([Data(trial).start Data(trial).end],{'g','r'},{'D�but','Fin'})
% legend('normal','without hand','without GH','without SCAC','without RoB')
% subplot(1,2,2)
% plot(Data(trial).deltahand') ; hold on
% plot(Data(trial).deltaGH')
% plot(Data(trial).deltaSCAC')
% plot(Data(trial).deltaRoB')
% vline([Data(trial).start Data(trial).end],{'g','r'},{'D�but','Fin'})
% legend('contrib hand','contrib GH','contrib SCAC','contrib RoB')
% 
% for i = 1 : length(Data)
% plot(Data(i).deltahand') ; hold on
% plot(Data(i).deltaGH')
% plot(Data(i).deltaSCAC')
% plot(Data(i).deltaRoB')
% vline([Data(i).start/20 Data(i).end/20],{'g','r'},{'D�but','Fin'})
% legend('contrib hand','contrib GH','contrib SCAC','contrib RoB')
% figure
% end