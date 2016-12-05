%   Description:
%       contribution_hauteur_traitement is used to compute the contribution of each
%       articulation to the height
%   Output:
%       contribution_hauteur gives SPM output and graph
%   Functions:
%       contribution_hauteur uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%   Date:    29-Nov-2016; Last revision: 1-Dec-2016
%_____________________________________________________________________________

clear all; close all; clc

%% Chargement des fonctions
if isempty(strfind(path, '\\10.89.24.15\e\Librairies\S2M_Lib\'))
    % Librairie S2M
    loadS2MLib;
end
%% Interrupteur
plot        =  0;                   % 0 ou 1
stat        =  1;                   % 0 ou 1 
comparaison = '%';                 % = (absolu) ou % (relatif)
%% Dossiers
path.datapath = '\\10.89.24.15\e\\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_hauteur\elaboratedData_mat\';

%% Chargement des données
alias.matname = dir([path.datapath '*mat']);

for i = 1 : length(alias.matname)
    RAW(i) = load([path.datapath alias.matname(i).name]);
end

% Grande structure de données
bigstruct    = struct2array(RAW);

%% Choix de la comparaison (absolu ou relatif)
if     comparaison == '='
    for i = length(bigstruct):-1:1
        if bigstruct(i).poids == 18
            bigstruct(i) = [];
        end
    end
elseif comparaison == '%'
    for i = length(bigstruct):-1:1
        if bigstruct(i).poids == 6 && bigstruct(i).sexe == 'H'
            bigstruct(i) = [];
        elseif bigstruct(i).poids == 12 && bigstruct(i).sexe == 'H'
            bigstruct(i).poids = 0;
        elseif bigstruct(i).poids == 18 && bigstruct(i).sexe == 'H'
            bigstruct(i).poids = 1;
        elseif bigstruct(i).poids == 6 && bigstruct(i).sexe == 'F'
            bigstruct(i).poids = 0;
        elseif bigstruct(i).poids == 12 && bigstruct(i).sexe == 'F'
            bigstruct(i).poids = 1;
        end
    end
end

%% Facteurs
% Sexe
sexe    = cellstr(vertcat(bigstruct(:).sexe));
% Hauteur
hauteur = vertcat(bigstruct(:).hauteur);
% Poids
poids   = vertcat(bigstruct(:).poids);

%% Variables
% nombre de frames désirés pour interpolation
nbframe = 200;

% Transformation des données vers GRAMM friendly

for i = 1 : length(bigstruct)
    % Transformation en cellules (pour input SPM et gramm)
    % Les essais sont découpés avec le capteur de force
    delta_hand{i,1} = bigstruct(i).deltahand(round(bigstruct(i).start):round(bigstruct(i).end));
    delta_GH{i,1}   = bigstruct(i).deltaGH(round(bigstruct(i).start):round(bigstruct(i).end));
    delta_SCAC{i,1} = bigstruct(i).deltaSCAC(round(bigstruct(i).start):round(bigstruct(i).end));
    delta_RoB{i,1}  = bigstruct(i).deltaRoB(round(bigstruct(i).start):round(bigstruct(i).end));
    
    % Interpolation (pour avoir même nombre de frames)
    delta_hand{i,1} = ScaleTime(delta_hand{i,1}, 1, length(delta_hand{i,1}), nbframe);
    delta_GH{i,1}   = ScaleTime(delta_GH{i,1}, 1, length(delta_GH{i,1}), nbframe);
    delta_SCAC{i,1} = ScaleTime(delta_SCAC{i,1}, 1, length(delta_SCAC{i,1}), nbframe);
    delta_RoB{i,1}  = ScaleTime(delta_RoB{i,1}, 1, length(delta_RoB{i,1}), nbframe);
end

% Vecteur X (temps en %)
time  = linspace(0,100,nbframe);


clearvars bigstruct i 
%% Plot
if plot == 1
    % Delta hand
    g(1,1)=gramm('x',time,'y',delta_hand,'color',sexe);
    g(1,1).geom_line();
    % g(1,1).stat_summary('type','std');
    g(1,1).set_names('x','Normalized time (% of trial)','y','Contribution to the height (% of max height)','color','Sex');
    g(1,1).set_title('Contribution of the hand on the height');
    
    % Delta GH
    g(1,2)=gramm('x',time,'y',delta_GH,'color',sexe);
    g(1,2).geom_line();
    % g(1,2).stat_summary('type','std');
    g(1,2).set_names('x','Normalized time (% of trial)','y','Contribution to the height (% of max height)','color','Sex');
    g(1,2).set_title('Comparison of GH on the height');
    
    % Delta SCAC
    g(2,1)=gramm('x',time,'y',delta_SCAC,'color',sexe);
    g(2,1).geom_line();
    % g(2,1).stat_summary('type','std');
    g(2,1).set_names('x','Normalized time (% of trial)','y','Contribution to the height (% of max height)','color','Sex');
    g(2,1).set_title('Comparison of SC & AC on the height');
    
    % Delta RoB
    g(2,2)=gramm('x',time,'y',delta_RoB,'color',sexe);
    g(2,2).geom_line();
    % g(2,2).stat_summary('type','std');
    g(2,2).set_names('x','Normalized time (% of trial)','y','Contribution to the height (% of max height)','color','Sex');
    g(2,2).set_title('Comparison of the rest of the body on the height');
    
    g.draw();
end
%% SPM
if stat == 1
    % Transformation des données
    for i = 1 : length(delta_hand)
        % Variables en colonnes
        SPM.delta_hand(i,:) = delta_hand{i,1}';
        SPM.delta_GH(i,:)   = delta_GH{i,1}';
        SPM.delta_SCAC(i,:) = delta_SCAC{i,1}';
        SPM.delta_RoB(i,:)  = delta_RoB{i,1}';
        
        % Facteurs
        if     sexe{i,1} == 'H'
            SPM.sexe(1,i) = 0;
        elseif sexe{i,1} == 'F'
            SPM.sexe(1,i) = 1;
        end
    end
    
    SPM.hauteur = hauteur';
    SPM.poids   = poids';
    
    % Tests statistiques
    %(1) Conduct SPM analysis:
    spmlist   = spm1d.stats.anova3(SPM.delta_hand, SPM.sexe, SPM.hauteur, SPM.poids);
    spmilist  = spmlist.inference(0.05);
    disp_summ(spmilist)
    
    
    %(2) Plot:
    close all
    spmilist.plot('plot_threshold_label',false, 'plot_p_values',true, 'autoset_ylim',true);
end