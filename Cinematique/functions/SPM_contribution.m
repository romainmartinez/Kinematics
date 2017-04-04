function [anova,interaction, mainA, mainB] = SPM_contribution(Y, A, B, SUBJ, delta, time, correctbonf)
%% Bonferonni correction
if correctbonf == 1
    % 4 ANOVA (for each delta)
    nanova  = 4;
    p.anova = spm1d.util.p_critical_bonf(0.05, nanova);
    % 4 repeated measures (4 delta) for 6 height = 24 tests
    nttest = 4*6;
    p.ttest = spm1d.util.p_critical_bonf(0.05, nttest);
else
    p.anova = 0.05;
    p.ttest = 0.05;
end
%% Two-way ANOVA with repeated-measures on one factor
anova2.spmlist  = spm1d.stats.anova2onerm(Y, A, B, SUBJ);
anova2.spmilist = anova2.spmlist.inference(p.anova);
index = 0;
for ieffect = 1 : 3
    for icluster = 1 : anova2.spmilist.SPMs{1, ieffect}.nClusters
        index = index + 1;
        anova(index).delta  = delta;
        anova(index).effect = anova2.spmilist.SPMs{1, ieffect}.effect;
        anova(index).df1    = anova2.spmilist.SPMs{1, ieffect}.df(1);
        anova(index).df2    = anova2.spmilist.SPMs{1, ieffect}.df(2);
        anova(index).p      = anova2.spmilist.SPMs{1, ieffect}.p(icluster);
        anova(index).start  = round(anova2.spmilist.SPMs{1, ieffect}.clusters{1, icluster}.endpoints(1));
        anova(index).end    = round(anova2.spmilist.SPMs{1, ieffect}.clusters{1, icluster}.endpoints(2));
        if anova(index).start == 0
            anova(index).start = 1;
        end
        anova(index).diff = mean2(Y(A == 1,anova(index).start:anova(index).end)) - mean2(Y(A == 2,anova(index).start:anova(index).end));
    end
end
%% 1) Interaction sex - height
if anova2.spmilist.SPMs{1, 3}.h0reject == 1
    [roi] = SPM_roi(anova2.spmilist.SPMs{1, 3}.clusters);     % Region of Interest
    index = 0;
    
    for iHauteur = 1 : 6
        ttest.spm = spm1d.stats.ttest2(Y(A == 1 & B == iHauteur,:),... % men
            Y(A == 2 & B == iHauteur,:),... % women
            'roi',roi);
        ttest.spmi = ttest.spm.inference(p.ttest, 'two_tailed', true);
        if ttest.spmi.h0reject == 1
            for iCluster = 1 : ttest.spmi.nClusters
                index = index + 1;
                interaction(index).delta = delta;
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
                interaction(index).meanM = mean(ttest.spmi.beta(1,:));
                interaction(index).meanW = mean(ttest.spmi.beta(2,:));
                interaction(index).maxM  = max(ttest.spmi.beta(1,:));
                interaction(index).maxW  = max(ttest.spmi.beta(2,:));
                interaction(index).timeM = mean(time(A == 1 & B == iHauteur));
                interaction(index).timeW = mean(time(A == 2 & B == iHauteur));
            end
        end
    end
else
    interaction = [];
end
%% 2) Main effect sex
if anova2.spmilist.SPMs{1, 1}.h0reject == 1
    index = 0;
    for iCluster = 1 : anova2.spmilist.SPMs{1, 1}.nClusters
        index = index + 1;
        mainA(index).delta = delta;
        mainA(index).comp  = 'Main A';
        mainA(index).df1 = anova2.spmilist.SPMs{1, 1}.df(1);
        mainA(index).df2 = anova2.spmilist.SPMs{1, 1}.df(2);
        mainA(index).p = anova2.spmilist.SPMs{1, 1}.p(iCluster);
        mainA(index).start = round(anova2.spmilist.SPMs{1, 1}.clusters{1, iCluster}.endpoints(1));
        mainA(index).end = round(anova2.spmilist.SPMs{1, 1}.clusters{1, iCluster}.endpoints(2));
        if mainA(index).start == 0
            mainA(index).start = 1;
        end
        mainA(index).diff = mean2(Y(A == 1,mainA(index).start:mainA(index).end)) - mean2(Y(A == 2,mainA(index).start:mainA(index).end));
    end
else
    mainA = [];
end
%% 3) Main effect height
if anova2.spmilist.SPMs{1, 2}.h0reject == 1
    index = 0;
    for iCluster = 1 : anova2.spmilist.SPMs{1, 2}.nClusters
        index = index + 1;
        mainB(index).delta = delta;
        mainB(index).comp  = 'Main B';
        mainB(index).df1 = anova2.spmilist.SPMs{1, 2}.df(1);
        mainB(index).df2 = anova2.spmilist.SPMs{1, 2}.df(2);
        mainB(index).p = anova2.spmilist.SPMs{1, 2}.p(iCluster);
        mainB(index).start = round(anova2.spmilist.SPMs{1, 2}.clusters{1, iCluster}.endpoints(1));
        mainB(index).end = round(anova2.spmilist.SPMs{1, 2}.clusters{1, iCluster}.endpoints(2));
        if mainB(index).start == 0
            mainB(index).start = 1;
        end
    end
else
    mainB = [];
end