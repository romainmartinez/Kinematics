function hauteur_SPM_posthoc(comparaison,
%% Combinaison de comparaison (colonne 1: hommes ; colonne 2 : femmes)
if comparaison == '%'
    test
end
%% sélection des données
data_hommes = SPM.delta_GH(SPM.condition == 7 & SPM.sexe == 0,:);
data_femmes = SPM.delta_GH(SPM.condition == 7 & SPM.sexe == 1,:);

%% Correction Bonferonni
% p est corrigé car on fait 4 mesures répétés (4 delta) pour 12
% conditions (6 hauteurs x 2 poids) = 48 tests
nbtrials = 4*6*2;
p_ttest = spm1d.util.p_critical_bonf(0.05, nbtrials);

%% T-tests
spm = spm1d.stats.ttest2(data_hommes, data_femmes);
spmi = spm.inference(p_ttest, 'two_tailed', true);
disp(spmi)
spmi.plot();
spmi.plot_threshold_label();
spmi.plot_p_values();

end

