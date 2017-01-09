function [export] = hauteur_SPM_anova(SPM)

% p est corrig� car on fait 4 ANOVA (pour chaque delta): 0.05/4
p_anova = spm1d.util.p_critical_bonf(0.05, 4);

% Analyse SPM
spmlist   = spm1d.stats.anova3(SPM.comp, SPM.sexe, SPM.hauteur, SPM.poids);
spmilist  = spmlist.inference(p_anova);

%% Param�tres d'exportation
for i = length(spmilist.SPMs) : -1 : 1
    export(i).effect   = spmilist.SPMs{1, i}.effect;
    export(i).df1      = spmilist.SPMs{1, i}.df(1);
    export(i).df2      = spmilist.SPMs{1, i}.df(2);
    export(i).h0reject = spmilist.SPMs{1, i}.h0reject;
    
    icluster = 0;
    if spmilist.SPMs{1, i}.h0reject == 1
        for n = 1 : spmilist.SPMs{1, i}.nClusters
            % Merge des zones avec diff�rence de moins de 10%
            if n ~= 1 && round(spmilist.SPMs{1, i}.clusters{1, n}.endpoints(1)/2) - round(spmilist.SPMs{1, i}.clusters{1, n-1}.endpoints(2)/2) < 10
                export(i).(['cluster' num2str(icluster) 'end']) = round(spmilist.SPMs{1, i}.clusters{1, n}.endpoints(1)/2);
            else
                icluster = icluster+1
                export(i).(['p' num2str(icluster)]) = spmilist.SPMs{1, i}.p(n);
                export(i).(['cluster' num2str(icluster) 'start']) = round(spmilist.SPMs{1, i}.clusters{1, n}.endpoints(1)/2);
                export(i).(['cluster' num2str(icluster) 'end'])   = round(spmilist.SPMs{1, i}.clusters{1, n}.endpoints(2)/2);
            end
        end
        
    end
    
end