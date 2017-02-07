function [interaction] = SPM_contribution(Y, A, B, SUBJ, delta, time, correctbonf, height)
%% Bonferonni correction
if correctbonf == 1
    % 4 ANOVA (for each delta)
    nanova = 4*2;
    p.anova = spm1d.util.p_critical_bonf(0.05, nanova);
    % 4 repeated measures (4 delta) for (2 height x 2 sex x 2 weight) = 32 tests
    nttest = 4*2*2*2;
    p.ttest = spm1d.util.p_critical_bonf(0.05, nttest);
else
    p.anova = 0.05;
    p.ttest = 0.05;
end
%% Two-way ANOVA with repeated-measures on one factor
anova2.spmlist  = spm1d.stats.anova2onerm(Y, A, B, SUBJ);
anova2.spmilist = anova2.spmlist.inference(p.anova);
disp_summ(anova2.spmilist)
index = 0;

if anova2.spmilist.SPMs{1, 3}.h0reject == 1                 % interaction AB
    [roi] = SPM_roi(anova2.spmilist.SPMs{1, 3}.clusters);   % Region of Interest
    perm = nchoosek(1:2,2);
    
    for iPerm = length (perm) : -1 : 1
        ttest.spm = spm1d.stats.ttest2(Y(A == 1 & B == perm(iPerm),:),... % men
                                       Y(A == 2 & B == perm(iPerm),:),... % women
                                       'roi',roi);
        ttest.spmi = ttest.spm.inference(p.ttest, 'two_tailed', true);
        disp(ttest.spmi)
        
        if ttest.spmi.h0reject == 1
            index = index + 1;
            interaction(index).delta = delta;
            interaction(index).comp  = 'Interaction AB';
            interaction(index).height = height;
            interaction(index).weight = perm(iPerm);
            interaction(index).df1 = ttest.spmi.df(1);
            interaction(index).df2 = ttest.spmi.df(2);
            
            for iCluster = 1 : ttest.spmi.nClusters
                interaction(index)
                interaction(index).cluster{iCluster,1} = ttest.spmi.clusters{1, iCluster}.P; % p
                interaction(index).cluster{iCluster,2} = round(ttest.spmi.clusters{1, iCluster}.endpoints(1)/2); % start
                interaction(index).cluster{iCluster,3} = round(ttest.spmi.clusters{1, iCluster}.endpoints(2)/2); % end
                if interaction(index).cluster{iCluster,2} == 0
                    interaction(index).cluster{iCluster,2} = 1;
                end
                interaction(index).cluster{iCluster,4} = mean(ttest.spmi.beta(1,interaction(index).cluster{iCluster,2}:interaction(index).cluster{iCluster,3})) - mean(ttest.spmi.beta(2,interaction(index).cluster{iCluster,2}:interaction(index).cluster{iCluster,3})); % diff
                if interaction(index).cluster{iCluster,4} > 0
                    interaction(index).cluster{iCluster,5}  = num2str('men');   % sup
                elseif interaction(index).cluster{iCluster,4} < 0
                    interaction(index).cluster{iCluster,5}  = num2str('women'); % sup
                    
                end
                interaction(index).cluster{iCluster,6}  = mean(ttest.spmi.beta(1,:));        % mean men
                interaction(index).cluster{iCluster,7}  = mean(ttest.spmi.beta(2,:));        % mean women
                interaction(index).cluster{iCluster,8}  = max(ttest.spmi.beta(1,:));         % max men
                interaction(index).cluster{iCluster,9}  = max(ttest.spmi.beta(2,:));         % max women
                interaction(index).cluster{iCluster,10} = mean(time(A == 1 & B == perm(iPerm))); % time men
                interaction(index).cluster{iCluster,11} = mean(time(A == 2 & B == perm(iPerm))); % time women
            end
        end
        
    end
    
% elseif anova2.spmilist.SPMs{1, 1}.h0reject == 1             % main effect A
%     [roi] = SPM_roi(anova2.spmilist.SPMs{1, 1}.clusters);   % Region of Interest
% elseif anova2.spmilist.SPMs{1, 2}.h0reject == 1             % main effect B
%     [roi] = SPM_roi(anova2.spmilist.SPMs{1, 2}.clusters);   % Region of Interest
    
end

%%  1) A:B|C (factor1:facto2|factor3)
% export.AB = posthoc_contribution(Y,A,B,C,anova3,'Interaction AB',p,[2 6 2], delta, time)

%%  2) A:C|B
% export.AC = posthoc_contribution(Y,A,C,B,anova3,'Interaction AC',p,[2 2 6], delta, time)

%%  3) B:C|A
% export.BC = posthoc_contribution(Y,B,C,A,anova3,'Interaction BC',p,[6 2 2], delta, time)

% export = struct2array(export);
end

