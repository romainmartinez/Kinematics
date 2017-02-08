%   Description:
%       contribution_hauteur_traitement is used to compute the contribution of each
%       articulation to the height
%   Output:
%       contribution_hauteur_traitement gives SPM output and graph
%   Functions:
%       contribution_hauteur_traitement uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
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

%% Interrupteur
test        =   0;                  % 0 ou 1
grammplot   =   0;                  % 0 ou 1 ou 2
plotmean    =   1;                  % 0 ou 1
verif       =   0;                  % 0 ou 1
stat        =   1;                  % 0 ou 1
correctbonf =   0;                  % 0 ou 1
exporter    =   1;                  % 0 ou 1
comparaison =  '%';                 % '=' (absolu) ou '%' (relatif)
variable    =  'hauteur';           % 'vitesse' ou 'hauteur'

%% Dossiers
path.Datapath = ['\\10.89.24.15\e\\Projet_IRSST_LeverCaisse\ElaboratedData\matrices\' variable '\'];
path.exportpath = '\\10.89.24.15\e\\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_articulation\SPM\';
alias.matname = dir([path.Datapath '*mat']);

%% Chargement des données
for i = length(alias.matname) : -1 : 1
    RAW(i) = load([path.Datapath alias.matname(i).name]);
    
    for u = 1 : length(RAW(i).temp)
        RAW(i).temp(u).sujet = alias.matname(i).name(1:end-4);
        RAW(i).temp(u).nsujet = i;
        if RAW(i).temp(u).sexe == 'F'
            RAW(i).temp(u).sexe = 2;
        elseif RAW(i).temp(u).sexe == 'H'
            RAW(i).temp(u).sexe = 1;
        end
    end
end
% Grande structure de données
bigstruct  = struct2array(RAW);

%% Choix de la comparaison (absolu ou relatif)
switch comparaison
    case '='
        for i = length(bigstruct):-1:1
            if bigstruct(i).poids == 18
                bigstruct(i) = [];
            elseif bigstruct(i).poids == 6
                bigstruct(i).poids = 1;
            elseif bigstruct(i).poids == 12
                bigstruct(i).poids = 2;
            end
        end
    case '%'
        for i = length(bigstruct):-1:1
            if bigstruct(i).poids == 6 && bigstruct(i).sexe == 1
                bigstruct(i) = [];
            elseif bigstruct(i).poids == 12 && bigstruct(i).sexe == 1
                bigstruct(i).poids = 1;
            elseif bigstruct(i).poids == 18 && bigstruct(i).sexe == 1
                bigstruct(i).poids = 2;
            elseif bigstruct(i).poids == 6 && bigstruct(i).sexe == 2
                bigstruct(i).poids = 1;
            elseif bigstruct(i).poids == 12 && bigstruct(i).sexe == 2
                bigstruct(i).poids = 2;
            end
        end
end

%% Facteurs
SPM.sexe    = vertcat(bigstruct(:).sexe)';
SPM.hauteur = vertcat(bigstruct(:).hauteur)';
SPM.poids   = vertcat(bigstruct(:).poids)';
SPM.duree   = vertcat(bigstruct(:).time)';
SPM.sujet   = vertcat(bigstruct(:).nsujet)';


%% Compter le nombre d'hommes et de femmes
% Nombre de femmes
femmes = sum(SPM.sexe == 2)/36;
% Nombre d'hommes
hommes = sum(SPM.sexe == 1)/36;

if femmes ~= hommes
    disp('Number of participants is not balanced: please add names in the blacklist')
end
%% Variables
% nombre de frames désirés pour interpolation
nbframe = 200;

% Transformation des données vers GRAMM & SPM friendly

for i = 1 : length(bigstruct)
    % Filtre passe-bas 25Hz
    bigstruct(i).deltahand = lpfilter(bigstruct(i).deltahand, 15, 100);
    bigstruct(i).deltaGH   = lpfilter(bigstruct(i).deltaGH, 15, 100);
    bigstruct(i).deltaSCAC = lpfilter(bigstruct(i).deltaSCAC, 15, 100);
    bigstruct(i).deltaRoB  = lpfilter(bigstruct(i).deltaRoB, 15, 100);
    
    % Interpolation (pour avoir méme nombre de frames)
    SPM.delta_hand(i,:) = ScaleTime(bigstruct(i).deltahand, 1, length(bigstruct(i).deltahand), nbframe);
    SPM.delta_GH(i,:)   = ScaleTime(bigstruct(i).deltaGH, 1, length(bigstruct(i).deltaGH), nbframe);
    SPM.delta_SCAC(i,:) = ScaleTime(bigstruct(i).deltaSCAC, 1, length(bigstruct(i).deltaSCAC), nbframe);
    SPM.delta_RoB(i,:)  = ScaleTime(bigstruct(i).deltaRoB, 1, length(bigstruct(i).deltaRoB), nbframe);
end

% Vecteur X (temps en %)
SPM.time  = linspace(0,100,nbframe);

%% Plot
if grammplot == 1
    for i = 2 : -1 : 1
        figure('units','normalized','outerposition',[0 0 1 1])
        % Delta hand
        g(1,1) = gramm('x', SPM.time ,'y', SPM.delta_hand, 'color', SPM.sexe, 'subset', SPM.hauteur == i);
        g(1,1).set_names('x','Normalized time (% of trial)','y','Contribution to the height (% of max height)','color','Sex');
        g(1,1).set_title('Contribution of the hand and elbow');
        
        % Delta GH
        g(1,2) = gramm('x',SPM.time,'y',SPM.delta_GH,'color',SPM.sexe, 'subset', SPM.hauteur == i);
        g(1,2).set_names('x','Normalized time (% of trial)','y','Contribution to the height (% of max height)','color','Sex');
        g(1,2).set_title('Contribution of GH');
        
        % Delta SCAC
        g(2,1) = gramm('x',SPM.time,'y',SPM.delta_SCAC,'color',SPM.sexe, 'subset', SPM.hauteur == i);
        g(2,1).set_names('x','Normalized time (% of trial)','y','Contribution to the height (% of max height)','color','Sex');
        g(2,1).set_title('Contribution of SC & AC');
        
        % Delta RoB
        g(2,2) = gramm('x',SPM.time,'y',SPM.delta_RoB,'color',SPM.sexe, 'subset', SPM.hauteur == i);
        g(2,2).set_names('x','Normalized time (% of trial)','y','Contribution to the height (% of max height)','color','Sex');
        g(2,2).set_title('Contribution of the rest of the body');
        
        if plotmean == 1
            g(1,1).stat_summary('type','std');
            g(1,2).stat_summary('type','std');
            g(2,1).stat_summary('type','std');
            g(2,2).stat_summary('type','std');
        else
            g(1,1).geom_line();
            g(1,2).geom_line();
            g(2,1).geom_line();
            g(2,2).geom_line();
        end
        
        switch i
            case 1
                g.set_title([' Hips - Shoulders (H' num2str(i) ')']);
            case 2
                g.set_title([' Hips - Eyes (H' num2str(i) ')']);
            case 3
                g.set_title([' Shoulders - Hips (H' num2str(i) ')']);
            case 4
                g.set_title([' Shoulders - Eyes (H' num2str(i) ')']);
            case 5
                g.set_title([' Eyes - Hips (H' num2str(i) ')']);
            case 6
                g.set_title([' Eyes - Shoulders (H' num2str(i) ')']);
        end
        g.draw();
    end
elseif grammplot == 2
    gramm_contribution(SPM)
end


%% SPM
if stat == 1
    for i = 4 : -1 : 1 % nombre de delta
        for h = 2 : -1 : 1 % nombre de hauteur (montée - descente)
            %% Choix de la variable
            [SPM, result(i).test, idx] = selectSPMvariable(SPM,i,h);
            %% SPM analysis
             [result(i).interaction(h).h,result(i).mainA(h).h,result(i).mainB(h).h] = SPM_contribution(SPM.comp(idx,:),...
                 SPM.sexe(idx),SPM.poids(idx),SPM.sujet(idx),i,SPM.duree(idx),correctbonf,h);
             
        end
    end
end

%% Exporter les resultats
if exporter == 1
    % cat structure
    export.interaction = [result(:).interaction];
    export.mainA       = [result(:).mainA];
    export.mainB       = [result(:).mainB];
    
    export.interaction = [export(:).interaction.h];
    export.mainA       = [export(:).mainA.h];
    export.mainB       = [export(:).mainB.h];
    
    
    % expand cell
    [export.posthoc]   = expandcellinstruct(export.posthoc  , 'cluster');
    
    % Headers
    out_posthoc = fieldnames(export.posthoc)';
    
    % transformer en cell
    export.posthoc = struct2cell(export.posthoc);
    
    % 2D to 3D cell
    export.posthoc = permute(export.posthoc,[3,1,2]);
    
    % matrice d'export
    export.posthoc = vertcat(out_posthoc,export.posthoc);
    
    if     comparaison == '%'
        xlswrite([path.exportpath variable '_relative_posthoc.xlsx'], export.posthoc, 'posthoc');
    elseif comparaison == '='
        xlswrite([path.exportpath variable '_absolute_posthoc.xlsx'], export.posthoc, 'posthoc');
    end
end
%% Verification
if verif == 1
    %         figure('units','normalized','outerposition',[0 0 1 1])
    %         for i = 1 : length(SPM.delta_hand)
    %             plot(SPM.delta_hand(i,:),'DisplayName',[num2str(i) ' : ' bigstruct(i).sujet bigstruct(i).trialname]);
    %             hold on
    %         end
    %
    %         figure('units','normalized','outerposition',[0 0 1 1])
    %         for i = 1 : length(SPM.delta_GH)
    %             plot(SPM.delta_GH(i,:),'DisplayName',[num2str(i) ' : ' bigstruct(i).sujet bigstruct(i).trialname]);
    %             hold on
    %         end
    %
    %         figure('units','normalized','outerposition',[0 0 1 1])
    %         for i = 1 : length(SPM.delta_SCAC)
    %             plot(SPM.delta_SCAC(i,:),'DisplayName',[num2str(i) ' : ' bigstruct(i).sujet bigstruct(i).trialname]);
    %             hold on
    %         end
    %
    %         figure('units','normalized','outerposition',[0 0 1 1])
    %         for i = 1 : length(SPM.delta_RoB)
    %             plot(SPM.delta_RoB(i,:),'DisplayName',[num2str(i) ' : ' bigstruct(i).sujet bigstruct(i).trialname]);
    %             hold on
    %         end
    %
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    height = 2;
    
    idx    = find(SPM.hauteur == height);
    
    figure('units','normalized','outerposition',[0 0 1 1])
    for i = 1 : length(idx)
        plot(SPM.delta_hand(idx(i),:),'DisplayName',[num2str(idx(i)) ' : ' bigstruct(idx(i)).sujet bigstruct(idx(i)).trialname]);
        hold on
    end
    
    figure('units','normalized','outerposition',[0 0 1 1])
    for i = 1 : length(idx)
        plot(SPM.delta_GH(idx(i),:),'DisplayName',[num2str(idx(i)) ' : ' bigstruct(idx(i)).sujet bigstruct(idx(i)).trialname]);
        hold on
    end
    
    figure('units','normalized','outerposition',[0 0 1 1])
    for i = 1 : length(idx)
        plot(SPM.delta_SCAC(idx(i),:),'DisplayName',[num2str(idx(i)) ' : ' bigstruct(idx(i)).sujet bigstruct(idx(i)).trialname]);
        hold on
    end
    
    figure('units','normalized','outerposition',[0 0 1 1])
    for i = 1 : length(idx)
        plot(SPM.delta_RoB(idx(i),:),'DisplayName',[num2str(idx(i)) ' : ' bigstruct(idx(i)).sujet bigstruct(idx(i)).trialname]);
        hold on
    end
    
    
end
