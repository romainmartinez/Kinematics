function [interaction, mainA, mainB] = SPM_contribution(Y, A, B, SUBJ, delta, time, correctbonf, height)
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
%% 1) Interaction sex - weight
if anova2.spmilist.SPMs{1, 3}.h0reject == 1                 % interaction AB
%     [roi] = SPM_roi(anova2.spmilist.SPMs{1, 3}.clusters);   % Region of Interest
    perm = nchoosek(1:2,2);
    index = 0;
    
    for iPerm = 1 : length (perm)
        ttest.spm = spm1d.stats.ttest2(Y(A == 1 & B == perm(iPerm),:),... % men
                                       Y(A == 2 & B == perm(iPerm),:),... % women
                                       'roi',roi);
        ttest.spmi = ttest.spm.inference(p.ttest, 'two_tailed', true);
        disp(ttest.spmi)
        if ttest.spmi.h0reject == 1
            interaction(iPerm).delta = delta;
            interaction(iPerm).comp  = 'Interaction AB';
            interaction(iPerm).height = height;
            interaction(iPerm).weight = perm(iPerm);
            interaction(iPerm).df1 = ttest.spmi.df(1);
            interaction(iPerm).df2 = ttest.spmi.df(2);
            for iCluster = 1 : ttest.spmi.nClusters
                index = index + 1;
                interaction(:,index) = interaction(:,iPerm);
                interaction(index).p = ttest.spmi.clusters{1, iCluster}.P;
                interaction(index).start = round(ttest.spmi.clusters{1, iCluster}.endpoints(1)/2);
                interaction(index).end = round(ttest.spmi.clusters{1, iCluster}.endpoints(2)/2);
                if interaction(index).start == 0
                    interaction(index).start = 1;
                end
                interaction(index).diff = mean(ttest.spmi.beta(1,interaction(index).start:interaction(index).end)) - mean(ttest.spmi.beta(2,interaction(index).start:interaction(index).end));
                if interaction(index).diff > 0
                    interaction(index).sup  = num2str('men');
                elseif interaction(index).diff < 0
                    interaction(index).sup  = num2str('women');
                end
                interaction(index).meanM = mean(ttest.spmi.beta(1,:));
                interaction(index).menW  = mean(ttest.spmi.beta(2,:));
                interaction(index).maxM  = max(ttest.spmi.beta(1,:));
                interaction(index).maxW  = max(ttest.spmi.beta(2,:));
                interaction(index).timeM = mean(time(A == 1 & B == perm(iPerm)));
                interaction(index).timeW = mean(time(A == 2 & B == perm(iPerm)));
            end
        end
    end
else
    interaction = [];
end
%% 2) Main effect sex
if anova2.spmilist.SPMs{1, 1}.h0reject == 1             % main effect A (sex)
    index = 0;
    mainA(1).delta = delta;
    mainA(1).comp  = 'Main A';
    mainA(1).height = height;
    mainA(1).df1 = anova2.spmilist.SPMs{1, 1}.df(1);
    mainA(1).df2 = anova2.spmilist.SPMs{1, 1}.df(2);
    for iCluster = 1 : anova2.spmilist.SPMs{1, 1}.nClusters
        index = index + 1;
        mainA(:,index) = mainA(:,1);
        mainA(index).p = anova2.spmilist.SPMs{1, 1}.p;
        mainA(index).start = round(anova2.spmilist.SPMs{1, 1}.clusters{1, iCluster}.endpoints(1)/2);
        mainA(index).end = round(anova2.spmilist.SPMs{1, 1}.clusters{1, iCluster}.endpoints(2)/2);
        if mainA(index).start == 0
            mainA(index).start = 1;
        end
    end
else
    mainA = [];
end
%% 3) Main effect weight
if anova2.spmilist.SPMs{1, 2}.h0reject == 1             % main effect B (weight)
    index = 0;
    mainB(1).delta = delta;
    mainB(1).comp  = 'Main B';
    mainB(1).height = height;
    mainB(1).df1 = anova2.spmilist.SPMs{1, 2}.df(1);
    mainB(1).df2 = anova2.spmilist.SPMs{1, 2}.df(2);
    for iCluster = 1 : anova2.spmilist.SPMs{1, 2}.nClusters
        index = index + 1;
        mainB(:,index) = mainB(:,1);
        mainB(index).p = anova2.spmilist.SPMs{1, 2}.p;
        mainB(index).start = round(anova2.spmilist.SPMs{1, 2}.clusters{1, iCluster}.endpoints(1)/2);
        mainB(index).end = round(anova2.spmilist.SPMs{1, 2}.clusters{1, iCluster}.endpoints(2)/2);
        if mainB(index).start == 0
            mainB(index).start = 1;
        end
    end
else
    mainB = [];
end
% export = struct2array(export);
end

