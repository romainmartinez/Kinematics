%   Description:
%       contribution_hauteur_traitement is used to compute the contribution of each
%       articulation to the height
%   Output:
%       contribution_hauteur give SPM output and graph
%   Functions:
%       contribution_hauteur uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%   Date:    29-Nov-2016; Last revision: 29-Nov-2016
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
sujets(i) = load([path.datapath alias.matname(i).name]);
end

%% Facteurs
for s = 1 : length(sujets)
sexe(1,i)
end

subject = 4;

sujets(subject).data(1).deltahand

plot(sujets(subject).data(1).deltahand') ; hold on
plot(sujets(subject).data(1).deltaGH')
plot(sujets(subject).data(1).deltaSCAC')
plot(sujets(subject).data(1).deltaRoB')
vline([Data(i).start/20 Data(i).end/20],{'g','r'},{'Début','Fin'})
legend('contrib hand','contrib GH','contrib SCAC','contrib RoB')
figure

