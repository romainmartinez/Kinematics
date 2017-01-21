function [export, zeroD] = hauteur_SPM_posthoc(comparaison, SPM, delta)
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
    export(i).delta    = delta;
    export(i).men      = test(i,1);
    export(i).women    = test(i,2);
    export(i).df1      = spmi.df(1);
    export(i).df2      = spmi.df(2);
    export(i).h0reject = spmi.h0reject;
    
    %% Exportation 0D
    zeroD(i).delta      = delta;
    zeroD(i).men        = test(i,1);
    zeroD(i).women      = test(i,2);
    zeroD(i).moy_men    = mean(spmi.beta(1,:));
    zeroD(i).moy_women  = mean(spmi.beta(2,:));
    zeroD(i).time_men   = mean(SPM.duree(SPM.condition == test(i,1) & SPM.sexe == 0));
    zeroD(i).time_women = mean(SPM.duree(SPM.condition == test(i,2) & SPM.sexe == 1));
    
    icluster = 0;
    if spmi.h0reject == 1
        for n = 1 : spmi.nClusters
            if n ~= 1 && round(spmi.clusters{1, n}.endpoints(1)/2) - round(spmi.clusters{1, n-1}.endpoints(2)/2) < 10
                % Merge des zones avec différence de moins de 10%
                export(i).cluster{icluster,3} = round(spmi.clusters{1, n}.endpoints(1)/2);
                
            else
                icluster = icluster+1;
                
                export(i).cluster{icluster,1} = spmi.p(n);
                export(i).cluster{icluster,2} = round(spmi.clusters{1, n}.endpoints(1)/2);
                export(i).cluster{icluster,3} = round(spmi.clusters{1, n}.endpoints(2)/2);
                
                if export(i).cluster{icluster,2} == 0
                    export(i).cluster{icluster,2} = 1;
                end
            end
            
            % Obtenir le % de différence dans les zones significatives
            export(i).cluster{icluster,4} = mean(spmi.beta(1,export(i).cluster{icluster,2}:export(i).cluster{icluster,3})) - mean(spmi.beta(2,export(i).cluster{icluster,2}:export(i).cluster{icluster,3}));
            if export(i).cluster{icluster,4} > 0
                export(i).cluster{icluster,5} = 'men>women';
            else
                export(i).cluster{icluster,5} = 'women>men';
            end
            
        end
        %% Plot SPM
        subplot(2,1,1)
        spmi.plot();
        spmi.plot_threshold_label();
        spmi.plot_p_values();
        
        subplot(2,1,2)
        plot(spmi.beta(1,:), 'linewidth', 2) % hommes
        hold on
        plot(spmi.beta(2,:), 'linewidth', 2) % femmes
        legend('men', 'women')
        title([num2str(delta) '_' num2str(test(i,1)) ' vs ' num2str(test(i,2)) ])
        
        hgsave(gcf, ['\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_hauteur\figures\SPM_raw\' num2str(delta) '\' num2str(test(i,1)) 'vs' num2str(test(i,2))]);
        close(gcf);
    end
    
    clearvars spmi
end

