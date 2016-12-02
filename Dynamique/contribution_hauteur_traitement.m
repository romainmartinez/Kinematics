%   Description:
%       contribution_hauteur_traitement is used to compute the contribution of each
%       articulation to the height
%   Output:
%       contribution_hauteur gives SPM output and graph
%   Functions:
%       contribution_hauteur uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%   Date:    29-Nov-2016; Last revision: 1-Dec-2016
%_____________________________________________________________________________

clear all; close all; clc

%% Chargement des fonctions
if isempty(strfind(path, '\\10.89.24.15\e\Librairies\S2M_Lib\'))
    % Librairie S2M
    loadS2MLib;
end

%% Dossiers
path.datapath = '\\10.89.24.15\e\\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_hauteur\elaboratedData_mat\';

%% Chargement des données
alias.matname = dir([path.datapath '*mat']);

for i = 1 : length(alias.matname)
    RAW(i) = load([path.datapath alias.matname(i).name]);
end

% Grande structure de données
bigstruct    = struct2array(RAW);
%% Facteurs
% Sexe
sexe    = cellstr(vertcat(bigstruct(:).sexe));
% Hauteur
hauteur = vertcat(bigstruct(:).hauteur);
% Poids
poids   = vertcat(bigstruct(:).poids);

%% Variables
% nombre de frames désirés pour interpolation
nbframe = 200;
for i = 1 : length(bigstruct)
    % Transformation en cellules (pour input SPM et gramm)
    % Les essais sont découpés avec le capteur de force
    delta_hand{i,1} = bigstruct(i).deltahand(round(bigstruct(i).start):round(bigstruct(i).end));
    delta_GH{i,1}   = bigstruct(i).deltaGH(round(bigstruct(i).start):round(bigstruct(i).end));
    delta_SCAC{i,1} = bigstruct(i).deltaSCAC(round(bigstruct(i).start):round(bigstruct(i).end));
    delta_RoB{i,1}  = bigstruct(i).deltaRoB(round(bigstruct(i).start):round(bigstruct(i).end));
    
    % Interpolation (pour avoir même nombre de frames)
    delta_hand{i,1} = ScaleTime(delta_hand{i,1}, 1, length(delta_hand{i,1}), nbframe);
    delta_GH{i,1}   = ScaleTime(delta_GH{i,1}, 1, length(delta_GH{i,1}), nbframe);
    delta_SCAC{i,1} = ScaleTime(delta_SCAC{i,1}, 1, length(delta_SCAC{i,1}), nbframe);
    delta_RoB{i,1}  = ScaleTime(delta_RoB{i,1}, 1, length(delta_RoB{i,1}), nbframe);
end

% Vecteur X (temps en %)
time = linspace(0,100,nbframe);

g(1)=gramm('x',time,'y',delta_RoB,'color',sexe);
% g(1).geom_line();
g(1).stat_summary('type','std');
g(1).set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g(1).set_title('Comparison of wrist abduction');
g.draw();


clearvars bigstruct i 
%% test
subject = 25;
for subject = 1 : length(sujets)
    figure
plot(sujets(subject).data(1).deltahand') ; hold on
plot(sujets(subject).data(1).deltaGH')
plot(sujets(subject).data(1).deltaSCAC')
plot(sujets(subject).data(1).deltaRoB')
vline([sujets(subject).data(1).start sujets(subject).data(1).end],{'g','r'},{'Début','Fin'})
legend('contrib hand','contrib GH','contrib SCAC','contrib RoB')
end
