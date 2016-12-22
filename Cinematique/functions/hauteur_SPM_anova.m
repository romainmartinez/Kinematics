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
    
    if spmilist.SPMs{1, i}.h0reject == 1
        for n = 1 : spmilist.SPMs{1, i}.nClusters
            export(i).(['p' num2str(n)]) = spmilist.SPMs{1, i}.p(n);
            export(i).(['cluster' num2str(n) 'start']) = round(spmilist.SPMs{1, i}.clusters{1, n}.endpoints(1)/2);
            export(i).(['cluster' num2str(n) 'end'])   = round(spmilist.SPMs{1, i}.clusters{1, n}.endpoints(2)/2);
            
        end
    end
    
end