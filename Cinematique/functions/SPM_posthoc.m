function [ output_args ] = SPM_posthoc(SPM)
% | 12  men   vs 6  men
% | 12  men   vs 12 women
% | 12  men   vs 6  women
% | 6   men   vs 12 women
% | 6   men   vs 6  women
% | 12  women vs 6  women

A = unique(SPM.sex);
B = unique(SPM.weight);

% all possible combination with the provided factors
tests = combnk(1:length(A)+length(B),2)

for itests = 1 : length(tests)
    ttest.spm = spm1d.stats.ttest2(SPM.comp(SPM.sex == 1 & SPM.weight == iHauteur,:),... % men
        SPM.comp(SPM.sex == 2 & SPM.weight == iHauteur,:),... % women
        'roi',roi);
    ttest.spmi = ttest.spm.inference(p.ttest, 'two_tailed', true);
end

