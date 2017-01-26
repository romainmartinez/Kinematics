function [q_correct] = anatomical_correction(sujet, num_model, model, save_fig)
% Path
importPath = ['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\' sujet 'd\MODEL' num2str(round(num_model)) '\'];
exportPath = ['\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_articulation\figures\anatomical_corrected\'];
Qnames     = dir([importPath '*_MOD' num2str(num_model) '*' 'r' '*.Q*']);

% load relax trial
Q = load([importPath Qnames.name], '-mat');

% mean
if length(fieldnames(Q)) == 3
    Q0 = mean(Q.Q2,2);
elseif length(fieldnames(Q)) == 1
    Q0 = mean(Q.Q1,2);
end

% anatomical correction
[q_correct] = positionanato(Q0, model, 0);

if save_fig == 1
    S2M_rbdl_ShowModel(model, Q0, 'rt', true, 'comi', false, 'tags', true, 'com', false)
    axis equal
    axis tight
    saveas(gcf,[exportPath sujet],'fig')
end


