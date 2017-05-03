%   Description: used to compute the contribution of each articulation to the height
%   Output:  gives SPM output and graph
%   Functions: uses functions present in //10.89.24.15/e/Project_IRSST_LeverCaisse/Codes/Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%_____________________________________________________________________________

clear variables; close all; clc

path2 = load_functions('linux', 'Kinematics/Cinematique');

%% Switch
variable    =  'hauteur';           % 'vitesse' ou 'hauteur'
weight      =   [12,6];             % first: men's weight | second: women's weight
samesex     =   1;                  % 0 ou 1 (men) ou 2 (women)
correctbonf =   1;                  % 0 ou 1
exporter    =   1;                  % 0 ou 1
grammplot   =   1;                  % 0 ou 1 ou 2

%% Path
path2.Datapath = [path2.E '/Projet_IRSST_LeverCaisse/ElaboratedData/matrices/' variable '/'];
path2.exportpath = [path2.E '/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_articulation/SPM/'];
alias.matname = dir([path2.Datapath '*mat']);

%% load data
for i = length(alias.matname) : -1 : 1
    RAW(i) = load([path2.Datapath alias.matname(i).name]);
    
    for u = 1 : length(RAW(i).temp)
        RAW(i).temp(u).sujet = alias.matname(i).name(1:end-4);
        RAW(i).temp(u).nsujet = i;
        if RAW(i).temp(u).sexe == 'F'
            RAW(i).temp(u).sexe = 2;
        elseif RAW(i).temp(u).sexe == 'H'
            RAW(i).temp(u).sexe = 1;
        end
    end
end
% big structure of data
bigstruct  = struct2array(RAW);

% select weight
bigstruct = select_weight(bigstruct, weight, samesex);

%% Factors
SPM.sex = vertcat(bigstruct(:).sexe)';
SPM.height = vertcat(bigstruct(:).hauteur)';
SPM.weight = vertcat(bigstruct(:).poids)';
SPM.time = vertcat(bigstruct(:).time)';
SPM.subject = vertcat(bigstruct(:).nsujet)';

%% Number of men & women
femmes = sum(SPM.sexe == 2)/36;
hommes = sum(SPM.sexe == 1)/36;
if femmes ~= hommes
    disp('Number of participants is not balanced: please add names in the blacklist')
end
%% Variables
% number of frames
nbframe = 100;

% Transform dataframe into GRAMM & SPM friendly
for i = 1 : length(bigstruct)
    % low-pass filter 25Hz
    bigstruct(i).deltahand = lpfilter(bigstruct(i).deltahand, 15, 100);
    bigstruct(i).deltaGH   = lpfilter(bigstruct(i).deltaGH, 15, 100);
    bigstruct(i).deltaSCAC = lpfilter(bigstruct(i).deltaSCAC, 15, 100);
    bigstruct(i).deltaRoB  = lpfilter(bigstruct(i).deltaRoB, 15, 100);
    
    % interpolation
    SPM.deltahand(i,:) = ScaleTime(bigstruct(i).deltahand, 1, length(bigstruct(i).deltahand), nbframe);
    SPM.deltaGH(i,:)   = ScaleTime(bigstruct(i).deltaGH, 1, length(bigstruct(i).deltaGH), nbframe);
    SPM.deltaSCAC(i,:) = ScaleTime(bigstruct(i).deltaSCAC, 1, length(bigstruct(i).deltaSCAC), nbframe);
    SPM.deltaRoB(i,:)  = ScaleTime(bigstruct(i).deltaRoB, 1, length(bigstruct(i).deltaRoB), nbframe);
    SPM.boite(i,:) = ScaleTime(bigstruct(i).boite, 1, length(bigstruct(i).boite), nbframe)';
end

% Vecteur X (time in %)
SPM.time  = linspace(0,100,nbframe);

%% SPM
for iDelta = 4 : -1 : 1 % delta
    %% variable
    [SPM, result(iDelta).test] = selectSPMvariable(SPM,iDelta);
    %% SPM analysis
    [result(iDelta).anova,result(iDelta).interaction] = SPM_contribution(...
        SPM.comp,SPM.sexe,SPM.hauteur,SPM.sujet,iDelta,SPM.duree,correctbonf);
end

%% Export results (xlsx)
if exporter == 1
    batch = {'anova', 'interaction'};
    for ibatch = 1 : length(batch)
        if isempty([result(:).(batch{ibatch})]) ~= 1
            % cat structure
            export.(batch{ibatch}) = [result(:).(batch{ibatch})];
            % headers
            header.(batch{ibatch}) = fieldnames(export.(batch{ibatch}))';
            % struct2cell
            export.(batch{ibatch}) = struct2cell(export.(batch{ibatch}));
            % 2D cell to 3D cell
            export.(batch{ibatch}) = permute(export.(batch{ibatch}),[3,1,2]);
            % export matrix
            export.(batch{ibatch}) = vertcat(header.(batch{ibatch}),export.(batch{ibatch}));
            
            cell2csv([path2.exportpath variable batch{ibatch} num2str(weight(1)) 'vs' num2str(weight(2)) '.csv'], export.(batch{ibatch}), ',');
        end
    end
end

%% plot
if grammplot == 1
    gramm_contribution(SPM);
end