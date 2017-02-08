function [ output_args ] = SPM_Hotelling( input_args )

    % MANOVA
    Y(:,:,1) = SPM.delta_hand(SPM.hauteur == 2 & SPM.poids == 1,:);
    Y(:,:,2) = SPM.delta_GH(SPM.hauteur == 2 & SPM.poids == 1,:);
    Y(:,:,3) = SPM.delta_SCAC(SPM.hauteur == 2 & SPM.poids == 1,:);
    Y(:,:,4) = SPM.delta_RoB(SPM.hauteur == 2 & SPM.poids == 1,:);
    spm       = spm1d.stats.manova1(Y, SPM.sexe(SPM.hauteur == 2 & SPM.poids == 1));
    spmi      = spm.inference(0.05);
    disp(spmi)
    
    % H2
    hommes = find(SPM.hauteur == 1 & SPM.sexe == 1 & SPM.poids == 1);
    femmes = find(SPM.hauteur == 1 & SPM.sexe == 2 & SPM.poids == 1);
    
    YA(:,:,1) = SPM.delta_hand(hommes,:);
    YA(:,:,2) = SPM.delta_GH(hommes,:);
    YA(:,:,3) = SPM.delta_SCAC(hommes,:);
    YA(:,:,4) = SPM.delta_RoB(hommes,:);
    
    YB(:,:,1) = SPM.delta_GH(femmes,:);
    YB(:,:,2) = SPM.delta_GH(femmes,:);
    YB(:,:,3) = SPM.delta_GH(femmes,:);
    YB(:,:,4) = SPM.delta_GH(femmes,:);
    
    spm       = spm1d.stats.hotellings2(YA, YB);
    spmi      = spm.inference(0.05);
    
    spmi.plot();
    spmi.plot_threshold_label();
    spmi.plot_p_values();
    
    spm       = spm1d.stats.ttest2(YA, YB);
spmi      = spm.inference(0.05, 'two_tailed',true, 'interp',true);
    
    
end

