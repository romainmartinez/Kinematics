function [ output_args ] = SPM_posthoc(SPM, roi)
% | 12  men   vs 6  men
% | 12  men   vs 12 women
% | 12  men   vs 6  women
% | 6   men   vs 12 women
% | 6   men   vs 6  women
% | 12  women vs 6  women

A = unique(SPM.sex);
B = unique(SPM.weight);

% all possible combination with the provided factors
tests = combnk(1:length(A)+length(B),2);

%           M 12    M 6     W 6     W 12
convert = {[1 1] ; [1 2] ; [2 1] ; [2 2]};

test2 = convert(tests);

for itests = 1 : length(tests)
    ttest.spm = spm1d.stats.ttest2(SPM.comp(SPM.sex == 1 & SPM.weight == iHauteur,:),... % men
        SPM.comp(SPM.sex == 2 & SPM.weight == iHauteur,:),... % women
        'roi',roi);
    ttest.spmi = ttest.spm.inference(p.ttest, 'two_tailed', true);
end

