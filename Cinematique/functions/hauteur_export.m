% function [ output_args ] = hauteur_export(result)

%% ANOVA
outfile = 'test.csv';

headers = fieldnames(result(1).anova);

fid=fopen(outfile,'wt');

% headers
fprintf(fid,'%s\t',headers{:});

% ligne vide
fprintf(fid,'\n');

% Effets
fprintf(fid,'%s\n',result(i).anova(:).effect);

% Degrés de liberté
fprintf(fid,'%d\t\n',vertcat(result(i).anova(:).df));


fclose(fid);