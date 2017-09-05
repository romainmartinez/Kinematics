function ttest = SPM_posthoc(SPM, roi, p)
% | 12  men   vs 6  men
% | 12  men   vs 12 women
% | 12  men   vs 6  women
% | 6   men   vs 12 women
% | 6   men   vs 6  women
% | 12  women vs 6  women

A = unique(SPM.sex);
B = unique(SPM.weight);

% all possible combination with the provided factors
factors = combnk(1:length(A)+length(B),2);

%           M 12    M  6     W 6     W 12
convert = {[1 12] ; [1 6] ; [2 6] ; [2 12]};

factors = convert(factors);

for itest = 1 : length(factors)    
    ttest(itest).spm = spm1d.stats.ttest2(SPM.comp(SPM.sex == factors{itest,1}(1) & SPM.weight == factors{itest,1}(2),:),... % men
        SPM.comp(SPM.sex == factors{itest,2}(1) & SPM.weight == factors{itest,2}(2),:),... % women
        'roi',roi);
    
    ttest(itest).spmi = ttest(itest).spm.inference(p.ttest, 'two_tailed', true);
    
   ttest(itest).factors = [factors(itest, 1), factors(itest, 2)];
end

