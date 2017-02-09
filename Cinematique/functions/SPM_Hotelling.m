function [export] = SPM_Hotelling(data)
iPoids = 1; % 1 (12-6) ou 2 (18-12)

p.H2    = spm1d.util.p_critical_bonf(0.05, 6);
p.ttest = spm1d.util.p_critical_bonf(0.05, 24);

for iHauteur = 1 : 6
    hommes = find(data.hauteur == iHauteur & data.sexe == 1 & data.poids == iPoids);
    femmes = find(data.hauteur == iHauteur & data.sexe == 2 & data.poids == iPoids);
    
    YA(:,:,1) = data.delta_hand(hommes,:);
    YA(:,:,2) = data.delta_GH(hommes,:);
    YA(:,:,3) = data.delta_SCAC(hommes,:);
    YA(:,:,4) = data.delta_RoB(hommes,:);
    YB(:,:,1) = data.delta_hand(femmes,:);
    YB(:,:,2) = data.delta_GH(femmes,:);
    YB(:,:,3) = data.delta_SCAC(femmes,:);
    YB(:,:,4) = data.delta_RoB(femmes,:);
    
    hotelling.spm  = spm1d.stats.hotellings2(YA, YB);
    hotelling.spmi = hotelling.spm.inference(p.H2);
    
    export(iHauteur).hotelling = hotelling.spmi;
    
%     subplot(3,2,iHauteur)
%     hotelling.spmi.plot();
%     hotelling.spmi.plot_threshold_label();
%     hotelling.spmi.plot_p_values();
    roi = [];
    for iDelta = 1 : 4
        [roi] = SPM_roi(hotelling.spmi.clusters);
        ttest.spm  = spm1d.stats.ttest2(YA(:,:,iDelta), YB(:,:,iDelta),'roi',roi);
        ttest.spmi = ttest.spm.inference(p.ttest, 'two_tailed',true, 'interp',true);
        disp(ttest.spmi)
        
        export(iHauteur).ttest(iDelta) = ttest.spmi;
    end
end