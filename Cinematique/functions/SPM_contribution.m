function [anova, posthoc] = SPM_contribution(SPM, idelta)

p.anova = 0.05;
nttest = 6;
p.ttest = spm1d.util.p_critical_bonf(0.05, nttest); % Bonferonni correction

% Two-way ANOVA with repeated-measures on one factor
anova2.spmlist  = spm1d.stats.anova2onerm(SPM.comp, SPM.sex, SPM.weight, SPM.subject);
anova2.spmilist = anova2.spmlist.inference(p.anova);
index = 0;

% export result
anova = SPM2mat(anova2, index, idelta, SPM, 'anova2w');

% posthoc
if anova2.spmilist.SPMs{1, 3}.h0reject == 1
    roi = SPM_roi(anova2.spmilist.SPMs{1, 3}.clusters);     % Region of Interest
    index = 0;
    
    ttest = SPM_posthoc(SPM, roi, p);
    
    % export result
    posthoc = SPM2mat(ttest, index, idelta, SPM, 'posthoc');
else
    posthoc = [];
end