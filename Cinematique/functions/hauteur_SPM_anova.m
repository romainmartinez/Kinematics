function [export] = hauteur_SPM_anova(SPM)

    % p est corrigé car on fait 4 ANOVA (pour chaque delta): 0.05/4
    p_anova = spm1d.util.p_critical_bonf(0.05, 4);
    
    % Analyse SPM
    spmlist   = spm1d.stats.anova3(SPM.delta_hand, SPM.sexe, SPM.hauteur, SPM.poids);
    spmilist  = spmlist.inference(p_anova);
    
    %% Paramètres d'exportation
    for i = 1 : length(spmilist.SPMs)
        export(i).effect   = spmilist.SPMs{1, i}.effect;
        export(i).df       = spmilist.SPMs{1, i}.df;
        export(i).p        = spmilist.SPMs{1, i}.p;
        export(i).h0reject = spmilist.SPMs{1, i}.h0reject;
        export(i).clusters = spmilist.SPMs{1, i}.clusters;
    end