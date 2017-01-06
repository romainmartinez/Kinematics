function [ sujets_export ] = sujets_valides
%% Importer la feuille exce
[~, ~, sujets] = xlsread('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_hauteur\IRSST_infos_sujets.xlsx',...
    'Global','A2:J61');

for iline = length(sujets) : -1 : 1
    if sujets{iline,10} == 'x'
        sujets_export{iline} = sujets{iline, 1};
        sujets_export{iline} = ['IRSST_' upper(sujets_export{iline}(2)) sujets_export{iline}(3:end-2) upper(sujets_export{iline}(end-1))];
    end
end

sujets_export = sujets_export(~cellfun('isempty',sujets_export));
end

