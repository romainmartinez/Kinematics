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
    
    icluster = 0;
    if spmi.h0reject == 1
        for n = 1 : spmi.nClusters
            % Merge des zones avec diff�rence de moins de 10%
            if n ~= 1 && round(spmi.clusters{1, n}.endpoints(1)/2) - round(spmi.clusters{1, n-1}.endpoints(2)/2) < 10
                export(i).cluster{icluster,3} = round(spmi.clusters{1, n}.endpoints(1)/2);
            else
                icluster = icluster+1;
                
                export(i).cluster{icluster,1} = spmi.p(n);
                export(i).cluster{icluster,2} = round(spmi.clusters{1, n}.endpoints(1)/2);
                export(i).cluster{icluster,3} = round(spmi.clusters{1, n}.endpoints(2)/2);
                
                if export(i).cluster{icluster,2} == 0
                    export(i).cluster{icluster,2} = 1;
                end
                
                % Obtenir le % de diff�rence dans les zones significatives
%                 export(i).(['cluster' num2str(n) 'diff']) = mean(spmi.beta(1,debut:fin)) - mean(spmi.beta(2,debut:fin));
%                 export(i).(['cluster' num2str(n) 'diff']) = mean(spmi.beta(1,debut:fin)) - mean(spmi.beta(2,debut:fin));
            end
        end
    end
    
    clearvars spmi
end

