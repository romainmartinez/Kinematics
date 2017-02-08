function [ output_args ] = SPM_Hotelling(data)
hommes = find(data.hauteur == 2 & data.sexe == 1 & data.poids == 1);
femmes = find(data.hauteur == 2 & data.sexe == 2 & data.poids == 1);

YA(:,:,1) = data.delta_hand(hommes,:);
YA(:,:,2) = data.delta_GH(hommes,:);
YA(:,:,3) = data.delta_SCAC(hommes,:);
YA(:,:,4) = data.delta_RoB(hommes,:);

YB(:,:,1) = data.delta_hand(femmes,:);
YB(:,:,2) = data.delta_GH(femmes,:);
YB(:,:,3) = data.delta_SCAC(femmes,:);
YB(:,:,4) = data.delta_RoB(femmes,:);

hotelling.spm  = spm1d.stats.hotellings2(YA, YB);
hotelling.spmi = hotelling.spm.inference(0.05);

hotelling.spmi.plot();
hotelling.spmi.plot_threshold_label();
hotelling.spmi.plot_p_values();

for i = 1 : 4
    spm  = spm1d.stats.ttest2(YA(:,:,i), YB(:,:,i));
    spmi = spm.inference(0.05, 'two_tailed',true, 'interp',true);
    disp(spmi)
    figure
    
    subplot(2,1,1)
    spmi.plot();
    spmi.plot_threshold_label();
    spmi.plot_p_values();
    
    subplot(2,1,2)
    plot(mean(YA(:,:,i))); hold on
    plot(mean(YB(:,:,i)))
    legend('men','women')
    switch i
        case 1
            title('contribution hand-elbow')
        case 2
            title('contribution GH')
        case 3
            title('contribution SCAC')
        case 4
            title('contribution RoB')
    end
end

