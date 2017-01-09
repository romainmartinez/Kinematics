function [export] = hauteur_SPM_posthoc(comparaison, SPM)
%% Combinaison de comparaison (colonne 1: hommes ; colonne 2 : femmes)
[test] = comparison(comparaison);

%% sélection des données
for i = length(test) : -1 : 1
    data_hommes = SPM.comp(SPM.condition == test(i,1) & SPM.sexe == 0,:);
    data_femmes = SPM.comp(SPM.condition == test(i,2) & SPM.sexe == 1,:);
    
    %% Correction Bonferonni
    % p est corrigé car on fait 4 mesures répétés (4 delta) pour 12
    % conditions (6 hauteurs x 2 poids) = 48 tests
    nbtrials = 4*6*2;
    p_ttest = spm1d.util.p_critical_bonf(0.05, nbtrials);
    
    %% T-tests
    spm = spm1d.stats.ttest2(data_hommes, data_femmes);
    spmi = spm.inference(p_ttest, 'two_tailed', true);
    
    %% Paramètres d'exportation
    export(i).men      = test(i,1);
    export(i).women    = test(i,2);
    export(i).df1      = spmi.df(1);
    export(i).df2      = spmi.df(2);
    export(i).h0reject = spmi.h0reject;
    
    if spmi.h0reject == 1
        for n = 1 : spmi.nClusters
            export(i).(['p' num2str(n)]) = spmi.p(n);
            debut = round(spmi.clusters{1, n}.endpoints(1));
            fin   = round(spmi.clusters{1, n}.endpoints(2));
            export(i).(['cluster' num2str(n) 'start']) = round(debut/2);
            export(i).(['cluster' num2str(n) 'end'])   = round(fin/2);
            
            if debut == 0,debut = 1;,end
            
            % Obtenir le % de différence dans les zones significatives
            export(i).(['cluster' num2str(n) 'diff']) = mean(spmi.beta(1,debut:fin)) - mean(spmi.beta(2,debut:fin));
            
        end
    end
    
    clearvars spmi
end

