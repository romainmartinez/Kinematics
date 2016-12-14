function [export] = hauteur_SPM_posthoc(comparaison, SPM)
%% Combinaison de comparaison (colonne 1: hommes ; colonne 2 : femmes)
[test] = comparison(comparaison);

%% s�lection des donn�es
for i = length(test) : -1 : 1
    data_hommes = SPM.delta_GH(SPM.condition == test(i,1) & SPM.sexe == 0,:);
    data_femmes = SPM.delta_GH(SPM.condition == test(i,2) & SPM.sexe == 1,:);
    
    %% Correction Bonferonni
    % p est corrig� car on fait 4 mesures r�p�t�s (4 delta) pour 12
    % conditions (6 hauteurs x 2 poids) = 48 tests
    nbtrials = 4*6*2;
    p_ttest = spm1d.util.p_critical_bonf(0.05, nbtrials);

    %% T-tests
    spm = spm1d.stats.ttest2(data_hommes, data_femmes);
    spmi = spm.inference(p_ttest, 'two_tailed', true);
    
    %% Param�tres d'exportation
    export(i).comp     = [num2str(test(i,1)) 'vs' num2str(test(i,2))];
    export(i).df       = spmi.df;
    export(i).p        = spmi.p;
    export(i).h0reject = spmi.h0reject;
    export(i).clusters = spmi.clusters;
    
    clearvars spmi
end

