%   Description:
%       contribution_vitesse_preparation is used to compute the contribution of each
%       articulation to the acceleration
%   Output:
%       contribution_vitesse_preparation gives matrix for input in SPM1D and GRAMM
%   Functions:
%       contribution_vitesse_preparation uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%_____________________________________________________________________________

clear all; close all; clc

%% Chargement des fonctions
if isempty(strfind(path, '\\10.89.24.15\e\Librairies\S2M_Lib\'))
    % Librairie S2M
    loadS2MLib;
end

% Fonctions locales
cd('C:\Users\marti\Documents\Codes\Kinematics\Cinematique\functions');

%% Interrupteurs
saveresults = 0;
test        = 0;
model       = 2.1;

%% Dossiers
path.Datapath = '\\10.89.24.15\e\\Projet_IRSST_LeverCaisse\ElaboratedData\matrices\cinematique\';
path.exportpath = '\\10.89.24.15\e\\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_articulation\SPM\';
alias.matname = dir([path.Datapath '*mat']);

%% Info sur le sujets et le model
alias.sujet = sujets_valides;
[segmentMarkers, segmentDoF] = segment_RBDL(round(model));
segmentDoF = struct2cell(segmentDoF);


for isujet = 1 %length(Alias.sujet) : -1 : 1
    % Open model
    Path.DirModels  = ['\\10.89.24.15\f\Data\Shoulder\Lib\' alias.sujet{isujet} 'd\Model_' num2str(round(model)) '\' 'Model.s2mMod'];
    model = S2M_rbdl('new',Path.DirModels);
    
    % load data
    load([path.Datapath alias.sujet{isujet} '.mat']);data = temp;clearvars temp
    
    % close model
    S2M_rbdl('delete', Alias.model);
end

%% Zone de test
for itrial = 1 : length(data)
    for iframe = 1 : length(data(itrial).Qdata.Q2)
        for isegment = 1 : 4
            % Calcul de la jacobienne pour le frame
            TJi = S2M_rbdl('TagsJacobian', model, data(itrial).Qdata.Q2(:,iframe));
            % calcul de la contribution de chaque segment à la vitesse du marqueur
            % 3 car Z ; 39 car main ; 43 + 43 + 39 --> x + y + z du marqueur 39
            contrib(isegment,iframe) = multiprod(TJi(43+43+39,segmentDoF{isegment}),data(itrial).Qdata.QDOT2(segmentDoF{isegment},iframe));
        end
    end
    data(itrial).contrib_HELB = contrib(1,:);
    data(itrial).contrib_GH   = contrib(2,:);
    data(itrial).contrib_SCAC = contrib(3,:);
    data(itrial).contrib_RoB  = contrib(4,:);
    clearvars contrib
end

plot(data(1).contrib_HELB(round(data(1).start):round(data(2).end)))
hold on
plot(data(2).contrib_HELB(round(data(2).start):round(data(2).end)))
plot(data(3).contrib_HELB(round(data(3).start):round(data(2).end)))