function [export] = posthoc_contribution(Y, factor1, factor2, factor3, anova3, string, p, level, delta, time)
index = 0;

%% permutation
perm.factor1 = nchoosek(1:level(1),2);
perm.factor2 = nchoosek(1:level(2),2);
perm.factor3 = nchoosek(1:level(3),2);

idx = find(strcmp([anova3.spmilist.effect_labels], string)); % find engine
%% factor1:factor2|factor3
if anova3.spmilist.SPMs{1, idx}.h0reject == 1
    % 2-way factor1:factor2|factor3
    for iFactor3 = 1 : level(3)
        anova2.spmlist  = spm1d.stats.anova2(Y(factor3 == iFactor3,:), factor1(factor3 == iFactor3), factor2(factor3 == iFactor3));
        anova2.spmilist = anova2.spmlist.inference(p.anova);
        %         disp_summ(anova2.spmilist)
        if anova2.spmilist.SPMs{1, 3}.h0reject == 1
            % 1-way factor1|(factor2,facteur3)
            for iFactor2 = 1 : level(2)
                anova1.spmlist  = spm1d.stats.anova1(Y(factor2 == iFactor2 & factor3 == iFactor3,:), factor1(factor2 == iFactor2 & factor3 == iFactor3));
                anova1.spmilist = anova1.spmlist.inference(p.anova);
                %                 disp(anova1.spmilist)
                if anova1.spmilist.h0reject == 1
                    % t-test perm.factor1(factor2,facteur3)
                    for iPerm = 1 : size(perm.factor1,1)
                        ttest.spm = spm1d.stats.ttest2(Y(factor1 == perm.factor1(iPerm,1) & factor2 == iFactor2 & factor3 == iFactor3,:), Y(factor1 == perm.factor1(iPerm,2) & factor2 == iFactor2 & factor3 == iFactor3,:));
                        ttest.spmi = ttest.spm.inference(p.ttest, 'two_tailed', true);
                        %                         disp(ttest.spmi)
                        if ttest.spmi.h0reject == 1
                            index = index + 1;
                            export(index).delta = delta;
                            export(index).comp  = string;
                            export(index).facteur2 = iFactor2;
                            export(index).facteur3 = iFactor3;
                            export(index).df1 = ttest.spmi.df(1);
                            export(index).df2 = ttest.spmi.df(2);
                            
                            icluster = 0;
                            for xi = 1 : ttest.spmi.nClusters
                                % merge < 10 % area
                                if xi ~= 1  && round(ttest.spmi.clusters{1, xi}.endpoints(1)/2) - round(ttest.spmi.clusters{1, xi-1}.endpoints(2)/2) < 10
                                    export(index).cluster{icluster,3} = round(ttest.spmi.clusters{1, xi}.endpoints(2)/2);
                                else
                                    icluster = icluster + 1;
                                    export(index).cluster{icluster,1} = ttest.spmi.clusters{1, xi}.P;
                                    export(index).cluster{icluster,2} = round(ttest.spmi.clusters{1, xi}.endpoints(1)/2);
                                    export(index).cluster{icluster,3} = round(ttest.spmi.clusters{1, xi}.endpoints(2)/2);
                                    if export(index).cluster{icluster,2} == 0
                                        export(index).cluster{icluster,2} = 1;
                                    end
                                end
                                export(index).cluster{icluster,4} = mean(ttest.spmi.beta(1,export(index).cluster{icluster,2}:export(index).cluster{icluster,3})) - mean(ttest.spmi.beta(2,export(index).cluster{icluster,2}:export(index).cluster{icluster,3}));
                                if export(index).cluster{icluster,4} > 0
                                    export(index).cluster{icluster,5}  = num2str(perm.factor1(iPerm,1));
                                    export(index).cluster{icluster,6}  = num2str(perm.factor1(iPerm,2));
                                    export(index).cluster{icluster,7}  = mean(ttest.spmi.beta(1,:));
                                    export(index).cluster{icluster,8}  = mean(ttest.spmi.beta(2,:));
                                    export(index).cluster{icluster,9}  = max(ttest.spmi.beta(1,:));
                                    export(index).cluster{icluster,10} = max(ttest.spmi.beta(2,:));
                                    export(index).cluster{icluster,11} = mean(time(factor1 == perm.factor1(iPerm,1) & factor2 == iFactor2 & factor3 == iFactor3));
                                    export(index).cluster{icluster,12} = mean(time(factor1 == perm.factor1(iPerm,2) & factor2 == iFactor2 & factor3 == iFactor3));
                                elseif export(index).cluster{icluster,4} < 0
                                    export(index).cluster{icluster,5}  = num2str(perm.factor1(iPerm,2));
                                    export(index).cluster{icluster,6}  = num2str(perm.factor1(iPerm,1));
                                    export(index).cluster{icluster,7}  = mean(ttest.spmi.beta(2,:));
                                    export(index).cluster{icluster,8}  = mean(ttest.spmi.beta(1,:));
                                    export(index).cluster{icluster,9}  = max(ttest.spmi.beta(2,:));
                                    export(index).cluster{icluster,10} = max(ttest.spmi.beta(1,:));
                                    export(index).cluster{icluster,11} = mean(time(factor1 == perm.factor1(iPerm,2) & factor2 == iFactor2 & factor3 == iFactor3));
                                    export(index).cluster{icluster,12} = mean(time(factor1 == perm.factor1(iPerm,1) & factor2 == iFactor2 & factor3 == iFactor3));
                                end
                                
                            end
                        end
                    end
                end
            end
        end
    end
else
    export = [];
    disp(['No ' string])
end

