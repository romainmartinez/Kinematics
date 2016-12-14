function [export] = hauteur_SPM_posthoc(comparaison, SPM)
%% Combinaison de comparaison (colonne 1: hommes ; colonne 2 : femmes)
[test] = comparison(comparaison);

%% sélection des données
for i = length(test) : -1 : 1
    data_hommes = SPM.delta_GH(SPM.condition == test(i,1) & SPM.sexe == 0,:);
    data_femmes = SPM.delta_GH(SPM.condition == test(i,2) & SPM.sexe == 1,:);
    
    %% Correction Bonferonni
    % p est corrigé car on fait 4 mesures répétés (4 delta) pour 12
    % conditions (6 hauteurs x 2 poids) = 48 tests
    nbtrials = 4*6*2;
    p_ttest = spm1d.util.p_critical_bonf(0.05, nbtrials);
    
    %% Affichage de la comparaison
    result(i).comp = [num2str(test(i,1)) 'vs' num2str(test(i,2))];
    
    %% T-tests
    spm = spm1d.stats.ttest2(data_hommes, data_femmes);
    result(i).spmi = spm.inference(p_ttest, 'two_tailed', true);
    disp(result(i).spmi)
    figure
    result(i).spmi.plot();
    result(i).spmi.plot_threshold_label();
    result(i).spmi.plot_p_values();
    
    %% Paramètres d'exportation
    export(i).df       = result(i).spmi.df;
    export(i).p        = result(i).spmi.p;
    export(i).h0reject = result(i).spmi.h0reject;
    export(i).clusters = result(i).spmi.clusters;
    
end

