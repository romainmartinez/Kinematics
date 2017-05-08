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
    
    for itest = 1 : length(test)
        if test(itest).spmi.h0reject == 1
            for icluster = 1 : test(itest).spmi.nClusters
                index = index + 1;
                output(index).delta = idelta;
                output(index).sex = [num2str(test(itest).factors{1}(1)) '-' num2str(test(itest).factors{2}(1))];
                output(index).weight = [num2str(test(itest).factors{1}(2)) '-' num2str(test(itest).factors{2}(2))];
                output(index).df1 = test(itest).spmi.df(1);
                output(index).df2 = test(itest).spmi.df(2);
                output(index).p = test(itest).spmi.clusters{1, icluster}.P;
                output(index).start = round(test(itest).spmi.clusters{1, icluster}.endpoints(1));
                output(index).end = round(test(itest).spmi.clusters{1, icluster}.endpoints(2));
                if output(index).start == 0
                    output(index).start = 1;
                end
                output(index).diff = mean(test(itest).spmi.beta(1,output(index).start:output(index).end)) - mean(test(itest).spmi.beta(2,output(index).start:output(index).end));
                if output(index).diff > 0
                    output(index).sup  = num2str('1st');
                elseif output(index).diff < 0
                    output(index).sup  = num2str('2nd');
                end
            end
        end
    end
    
else
    error('Please, choose anova2w or posthoc.')
end
