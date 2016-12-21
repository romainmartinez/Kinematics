function [export] = hauteur_SPM_posthoc(comparaison, SPM)
%% Combinaison de comparaison (colonne 1: hommes ; colonne 2 : femmes)
[test] = comparison(comparaison);

%% s�lection des donn�es
for i = length(test) : -1 : 1
    data_hommes = SPM.comp(SPM.condition == test(i,1) & SPM.sexe == 0,:);
    data_femmes = SPM.comp(SPM.condition == test(i,2) & SPM.sexe == 1,:);
    
    %% Correction Bonferonni
    % p est corrig� car on fait 4 mesures r�p�t�s (4 delta) pour 12
    % conditions (6 hauteurs x 2 poids) = 48 tests
    nbtrials = 4*6*2;
    p_ttest = spm1d.util.p_critical_bonf(0.05, nbtrials);
    
    %% T-tests
    spm = spm1d.stats.ttest2(data_hommes, data_femmes);
    spmi = spm.inference(p_ttest, 'two_tailed', true);
    
    %% Param�tres d'exportation
    export(i).men      = test(i,1);
    export(i).women    = test(i,2);
    export(i).df1      = spmi.df(1);
    export(i).df2      = spmi.df(2);
    export(i).h0reject = spmi.h0reject;
    
    if spmi.h0reject == 1
        for n = 1 : spmi.nClusters
            export(i).(['p' num2str(n)]) = spmi.p(n);
            export(i).(['cluster' num2str(n) 'start']) = round(spmi.clusters{1, n}.endpoints(1)/2);
            export(i).(['cluster' num2str(n) 'end'])   = round(spmi.clusters{1, n}.endpoints(2)/2);
        end
    end
    
    clearvars spmi
end

