function [export] = hauteur_SPM_anova(SPM)

% p est corrigé car on fait 4 ANOVA (pour chaque delta): 0.05/4
p_anova = spm1d.util.p_critical_bonf(0.05, 4);

% Analyse SPM
spmlist   = spm1d.stats.anova3(SPM.comp, SPM.sexe, SPM.hauteur, SPM.poids);
spmilist  = spmlist.inference(p_anova);

%% Paramètres d'exportation
for i = length(spmilist.SPMs) : -1 : 1
    export(i).effect   = spmilist.SPMs{1, i}.effect;
    export(i).df1      = spmilist.SPMs{1, i}.df(1);
    export(i).df2      = spmilist.SPMs{1, i}.df(2);
    export(i).h0reject = spmilist.SPMs{1, i}.h0reject;
    export(i).clusters = spmilist.SPMs{1, i}.clusters;
    export(i).p        = spmilist.SPMs{1, i}.p;
end