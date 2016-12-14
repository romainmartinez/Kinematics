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
%   Date:    29-Nov-2016; Last revision: 08-Dec-2016
%_____________________________________________________________________________

clear all; close all; clc

%% Chargement des fonctions
if isempty(strfind(path, '\\10.89.24.15\e\Librairies\S2M_Lib\'))
    % Librairie S2M
    loadS2MLib;
    cd('C:\Users\Romain\Google Drive\Codes\Kinematics\Cinematique\functions\')
end
%% Interrupteur
test        =   0;                  % 0 ou 1
grammplot   =   0;                  % 0 ou 1
plotmean    =   0;                  % 0 ou 1
verif       =   0;                  % 0 ou 1
stat        =   1;                  % 0 ou 1
comparaison =  '%';                 % '=' (absolu) ou '%' (relatif)

%% Dossiers
path.datapath = '\\10.89.24.15\e\\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_hauteur\elaboratedData_mat\';
alias.matname = dir([path.datapath '*mat']);

%% Chargement des donn�es
for i = 1 : length(alias.matname)
        RAW(i) = load([path.datapath alias.matname(i).name]);
        
        for u = 1 : length(RAW(i).data)
            RAW(i).data(u).sujet = alias.matname(i).name(1:end-4);
        end
end

% Grande structure de donn�es
bigstruct  = struct2array(RAW);

%% Choix de la comparaison (absolu ou relatif)
switch comparaison
    case '='
        for i = length(bigstruct):-1:1
            if bigstruct(i).poids == 18
                bigstruct(i) = [];
            end
        end
    case '%'
        for i = length(bigstruct):-1:1
            if bigstruct(i).poids == 6 && bigstruct(i).sexe == 'H'
                bigstruct(i) = [];
            elseif bigstruct(i).poids == 12 && bigstruct(i).sexe == 'H'
                bigstruct(i).poids = 1;
            elseif bigstruct(i).poids == 18 && bigstruct(i).sexe == 'H'
                bigstruct(i).poids = 2;
            elseif bigstruct(i).poids == 6 && bigstruct(i).sexe == 'F'
                bigstruct(i).poids = 1;
            elseif bigstruct(i).poids == 12 && bigstruct(i).sexe == 'F'
                bigstruct(i).poids = 2;
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

%% Compter le nombre d'hommes et de femmes
% Nombre de femmes
femmes = sum(cell2mat(sexe) == 'F')/36
% Nombre d'hommes
hommes = sum(cell2mat(sexe) == 'H')/36

if femmes ~= hommes
    disp('Number of participants is not balanced: please add names in the blacklist')
end
%% Variables
% nombre de frames d�sir�s pour interpolation
nbframe = 200;

% Transformation des donn�es vers GRAMM friendly

for i = 1 : length(bigstruct)
    % Transformation en cellules (pour input SPM et gramm)
    % Les essais sont d�coup�s avec le capteur de force
    delta_hand{i,1} = bigstruct(i).deltahand(round(bigstruct(i).start):round(bigstruct(i).end));
    delta_GH{i,1}   = bigstruct(i).deltaGH(round(bigstruct(i).start)  :round(bigstruct(i).end));
    delta_SCAC{i,1} = bigstruct(i).deltaSCAC(round(bigstruct(i).start):round(bigstruct(i).end));
    delta_RoB{i,1}  = bigstruct(i).deltaRoB(round(bigstruct(i).start) :round(bigstruct(i).end));
    
    % Interpolation (pour avoir m�me nombre de frames)
    delta_hand{i,1} = ScaleTime(delta_hand{i,1}, 1, length(delta_hand{i,1}), nbframe);
    delta_GH{i,1}   = ScaleTime(delta_GH{i,1}, 1, length(delta_GH{i,1}), nbframe);
    delta_SCAC{i,1} = ScaleTime(delta_SCAC{i,1}, 1, length(delta_SCAC{i,1}), nbframe);
    delta_RoB{i,1}  = ScaleTime(delta_RoB{i,1}, 1, length(delta_RoB{i,1}), nbframe);
    
    % Filtre passe-bas 25Hz
    delta_hand{i,1} = lpfilter(delta_hand{i,1}, 25, 100);
    delta_GH{i,1}   = lpfilter(delta_GH{i,1},   25, 100);
    delta_SCAC{i,1} = lpfilter(delta_SCAC{i,1}, 25, 100);
    delta_RoB{i,1}  = lpfilter(delta_RoB{i,1},  25, 100);
end

% Vecteur X (temps en %)
time  = linspace(0,100,nbframe);

%% Plot
if grammplot == 1
    for i = 6 : -1 : 1
        figure('units','normalized','outerposition',[0 0 1 1])
        % Delta hand
        g(1,1) = gramm('x', time ,'y', delta_hand, 'color', sexe, 'subset', hauteur == 1);
        g(1,1).set_names('x','Normalized time (% of trial)','y','Contribution to the height (% of max height)','color','Sex');
        g(1,1).set_title('Contribution of the hand and elbow');
        
        % Delta GH
        g(1,2) = gramm('x',time,'y',delta_GH,'color',sexe, 'subset', hauteur == i);
        g(1,2).set_names('x','Normalized time (% of trial)','y','Contribution to the height (% of max height)','color','Sex');
        g(1,2).set_title('Contribution of GH');
        
        % Delta SCAC
        g(2,1) = gramm('x',time,'y',delta_SCAC,'color',sexe, 'subset', hauteur == i);
        g(2,1).set_names('x','Normalized time (% of trial)','y','Contribution to the height (% of max height)','color','Sex');
        g(2,1).set_title('Contribution of SC & AC');
        
        % Delta RoB
        g(2,2) = gramm('x',time,'y',delta_RoB,'color',sexe, 'subset', hauteur == i);
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
end


%% SPM
if stat == 1
    % Transformation des donn�es
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
    
    SPM.hauteur   = hauteur';                          % hauteur
    SPM.poids     = poids';                            % poids
    SPM.condition = vertcat(bigstruct(:).condition)';   % conditions
    
    %% ANOVA
    % p est corrig� car on fait 4 ANOVA (pour chaque delta): 0.05/4
    p_anova = spm1d.util.p_critical_bonf(0.05, 4);
    
    % Analyse SPM
    spmlist   = spm1d.stats.anova3(SPM.delta_GH, SPM.sexe, SPM.hauteur, SPM.poids);
    spmilist  = spmlist.inference(p_anova);
    
    % Afficher les r�sultats
    disp_summ(spmilist)
    
    % Plotter les r�sultats
    spmilist.plot('plot_threshold_label',false, 'plot_p_values',true, 'autoset_ylim',false);
    %% Post-hoc
    [export] = hauteur_SPM_posthoc(comparaison, SPM);
    
    
    spm = spm1d.stats.ttest2(SPM.delta_hand, SPM.delta_GH);
    spmi = spm.inference(p_ttest, 'two_tailed', true);
    disp(spmi)
    spmi.plot();
    spmi.plot_threshold_label();
    spmi.plot_p_values();
    

end

%% V�rification
if verif == 1
    %     figure('units','normalized','outerposition',[0 0 1 1])
    %     for i = 1 : length(delta_hand)
    %         plot(delta_hand{i,1},'DisplayName',[num2str(i) ' : ' bigstruct(i).sujet bigstruct(i).trialname]);
    %         hold on
    %     end
    %
    %     figure('units','normalized','outerposition',[0 0 1 1])
    %     for i = 1 : length(delta_GH)
    %         plot(delta_GH{i,1},'DisplayName',[num2str(i) ' : ' bigstruct(i).sujet bigstruct(i).trialname]);
    %         hold on
    %     end
    %
    %     figure('units','normalized','outerposition',[0 0 1 1])
    %     for i = 1 : length(delta_SCAC)
    %         plot(delta_SCAC{i,1},'DisplayName',[num2str(i) ' : ' bigstruct(i).sujet bigstruct(i).trialname]);
    %         hold on
    %     end
    %
    %     figure('units','normalized','outerposition',[0 0 1 1])
    %     for i = 1 : length(delta_RoB)
    %         plot(delta_RoB{i,1},'DisplayName',[num2str(i) ' : ' bigstruct(i).sujet bigstruct(i).trialname]);
    %         hold on
    %     end
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    height = 4;
    
    idx    = find(hauteur == height);
    
    figure('units','normalized','outerposition',[0 0 1 1])
    for i = 1 : length(idx)
        plot(delta_hand{idx(i),1},'DisplayName',[num2str(idx(i)) ' : ' bigstruct(idx(i)).sujet bigstruct(idx(i)).trialname]);
        hold on
    end
    
    figure('units','normalized','outerposition',[0 0 1 1])
    for i = 1 : length(idx)
        plot(delta_GH{idx(i),1},'DisplayName',[num2str(idx(i)) ' : ' bigstruct(idx(i)).sujet bigstruct(idx(i)).trialname]);
        hold on
    end
    
    figure('units','normalized','outerposition',[0 0 1 1])
    for i = 1 : length(idx)
        plot(delta_SCAC{idx(i),1},'DisplayName',[num2str(idx(i)) ' : ' bigstruct(idx(i)).sujet bigstruct(idx(i)).trialname]);
        hold on
    end
    
    figure('units','normalized','outerposition',[0 0 1 1])
    for i = 1 : length(idx)
        plot(delta_RoB{idx(i),1},'DisplayName',[num2str(idx(i)) ' : ' bigstruct(idx(i)).sujet bigstruct(idx(i)).trialname]);
        hold on
    end
    
    
end