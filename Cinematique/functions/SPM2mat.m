function output = SPM2mat(test, index, idelta, SPM, varargin)
output = [];

if varargin{1} == 'anova2w'
    
    for ieffect = 1 : 3
        for icluster = 1 : test.spmilist.SPMs{1, ieffect}.nClusters
            index = index + 1;
            output(index).delta  = idelta;
            output(index).effect = test.spmilist.SPMs{1, ieffect}.effect;
            output(index).df1    = test.spmilist.SPMs{1, ieffect}.df(1);
            output(index).df2    = test.spmilist.SPMs{1, ieffect}.df(2);
            output(index).p      = test.spmilist.SPMs{1, ieffect}.p(icluster);
            output(index).start  = round(test.spmilist.SPMs{1, ieffect}.clusters{1, icluster}.endpoints(1));
            output(index).end    = round(test.spmilist.SPMs{1, ieffect}.clusters{1, icluster}.endpoints(2));
            if output(index).start == 0
                output(index).start = 1;
            end
            output(index).diff = mean2(SPM.comp(SPM.sex == 1,output(index).start:output(index).end)) - mean2(SPM.comp(SPM.sex == 2,output(index).start:output(index).end));
        end
    end
    
elseif varargin{1} == 'posthoc'
    
    for iHauteur = 1 : 6
        ttest.spm = spm1d.stats.ttest2(SPM.comp(SPM.sex == 1 & SPM.weight == iHauteur,:),... % men
            SPM.comp(SPM.sex == 2 & SPM.weight == iHauteur,:),... % women
            'roi',roi);
        ttest.spmi = ttest.spm.inference(p.ttest, 'two_tailed', true);
        if ttest.spmi.h0reject == 1
            for iCluster = 1 : ttest.spmi.nClusters
                index = index + 1;
                interaction(index).delta = idelta;
                interaction(index).comp  = 'Interaction AB';
                interaction(index).height = iHauteur;
                interaction(index).df1 = ttest.spmi.df(1);
                interaction(index).df2 = ttest.spmi.df(2);
                interaction(index).p = ttest.spmi.p(iCluster);
                interaction(index).start = round(ttest.spmi.clusters{1, iCluster}.endpoints(1));
                interaction(index).end = round(ttest.spmi.clusters{1, iCluster}.endpoints(2));
                if interaction(index).start == 0
                    interaction(index).start = 1;
                end
                interaction(index).diff = mean(ttest.spmi.beta(1,interaction(index).start:interaction(index).end)) - mean(ttest.spmi.beta(2,interaction(index).start:interaction(index).end));
                if interaction(index).diff > 0
                    interaction(index).sup  = num2str('men');
                elseif interaction(index).diff < 0
                    interaction(index).sup  = num2str('women');
                end
            end
        end
    end
    
else
    error('Please, choose anova or interaction.')
end

