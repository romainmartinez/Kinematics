function [export] = SPM_contribution(Y, A, B, C, delta, time)
%% Correction Bonferonni
% p est corrig� car on fait 4 ANOVA (pour chaque delta): 0.05/4
nanova = 4;
p.anova = spm1d.util.p_critical_bonf(0.05, nanova);
% 4 mesures r�p�t�s (4 delta) pour (6 hauteurs x 2 poids x 2 sexe) = 96 tests
nttest = 4*6*2*2;
p.ttest = spm1d.util.p_critical_bonf(0.05, nttest);

%% anova 3-way
anova3.spmlist  = spm1d.stats.anova3(Y, A, B, C);
anova3.spmilist = anova3.spmlist.inference(p.anova);
% disp_summ(anova3.spmilist)

%%  1) A:B|C (factor1:facto2|factor3)
export.AB = posthoc_contribution(Y,A,B,C,anova3,'Interaction AB',p,[2 6 2], delta, time)

%%  2) A:C|B
export.AC = posthoc_contribution(Y,A,C,B,anova3,'Interaction AC',p,[2 2 6], delta, time)

%%  3) B:C|A
export.BC = posthoc_contribution(Y,B,C,A,anova3,'Interaction BC',p,[6 2 2], delta, time)

export = struct2array(export);
end

