%   Description: used to compute the contribution of each articulation to the height
%   Output:  gives SPM output and graph
%   Functions: uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%_____________________________________________________________________________

clear variables; close all; clc

%% load functions
if isempty(strfind(path, '\\10.89.24.15\e\Librairies\S2M_Lib\'))
    % S2M library
    loadS2MLib;
end

% local functions
cd('C:\Users\marti\Documents\Codes\Kinematics\Cinematique\functions');

%% Switch
grammplot   =   1;                  % 0 ou 1 ou 2
stat        =   1;                  % 0 ou 1
correctbonf =   0;                  % 0 ou 1
exporter    =   1;                  % 0 ou 1
comparaison =  '%';                 % '=' (absolu) ou '%' (relatif)
variable    =  'hauteur';           % 'vitesse' ou 'hauteur'
poids       =   1;                  % 1 (12-6) ou 2 (18-12)

%% Path
path.Datapath = ['\\10.89.24.15\e\\Projet_IRSST_LeverCaisse\ElaboratedData\matrices\' variable '\'];
path.exportpath = '\\10.89.24.15\e\\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_articulation\SPM\';
alias.matname = dir([path.Datapath '*mat']);

%% load data
for i = length(alias.matname) : -1 : 1
    RAW(i) = load([path.Datapath alias.matname(i).name]);
    
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

%% Choice of comparison (absolute or relative)
switch comparaison
    case '='
        for i = length(bigstruct):-1:1
            if bigstruct(i).poids == 18
                bigstruct(i) = [];
            elseif bigstruct(i).poids == 6
                bigstruct(i).poids = 1;
            elseif bigstruct(i).poids == 12
                bigstruct(i).poids = 2;
            end
        end
    case '%'
        for i = length(bigstruct):-1:1
            if bigstruct(i).poids == 6 && bigstruct(i).sexe == 1
                bigstruct(i) = [];
            elseif bigstruct(i).poids == 12 && bigstruct(i).sexe == 1
                bigstruct(i).poids = 1;
            elseif bigstruct(i).poids == 18 && bigstruct(i).sexe == 1
                bigstruct(i).poids = 2;
            elseif bigstruct(i).poids == 6 && bigstruct(i).sexe == 2
                bigstruct(i).poids = 1;
            elseif bigstruct(i).poids == 12 && bigstruct(i).sexe == 2
                bigstruct(i).poids = 2;
            end
        end
end

%% Factors
SPM.sexe    = vertcat(bigstruct(:).sexe)';
SPM.hauteur = vertcat(bigstruct(:).hauteur)';
SPM.poids   = vertcat(bigstruct(:).poids)';
SPM.duree   = vertcat(bigstruct(:).time)';
SPM.sujet   = vertcat(bigstruct(:).nsujet)';

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
    SPM.delta_hand(i,:) = ScaleTime(bigstruct(i).deltahand, 1, length(bigstruct(i).deltahand), nbframe);
    SPM.delta_GH(i,:)   = ScaleTime(bigstruct(i).deltaGH, 1, length(bigstruct(i).deltaGH), nbframe);
    SPM.delta_SCAC(i,:) = ScaleTime(bigstruct(i).deltaSCAC, 1, length(bigstruct(i).deltaSCAC), nbframe);
    SPM.delta_RoB(i,:)  = ScaleTime(bigstruct(i).deltaRoB, 1, length(bigstruct(i).deltaRoB), nbframe);
end

% Vecteur X (time in %)
SPM.time  = linspace(0,100,nbframe);

%% SPM
if stat == 1
    for iDelta = 4 : -1 : 1 % delta
        %% variable
        [SPM, result(iDelta).test, idx] = selectSPMvariable(SPM,iDelta,poids);
        %% SPM analysis
        [result(iDelta).anova,result(iDelta).interaction,result(iDelta).mainA,result(iDelta).mainB] = SPM_contribution(...
            SPM.comp(idx,:),SPM.sexe(idx),SPM.hauteur(idx),SPM.sujet(idx),iDelta,SPM.duree(idx),correctbonf);
    end
end

%% Export results (xlsx)
if exporter == 1
    batch = {'anova', 'interaction', 'mainA', 'mainB'};
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
            
            if     comparaison == '%'
                xlswrite([path.exportpath variable '_relative.xlsx'], export.(batch{ibatch}), batch{ibatch});
            elseif comparaison == '='
                xlswrite([path.exportpath variable '_absolute.xlsx'], export.(batch{ibatch}), batch{ibatch});
            end
        end
    end
end
%% plot
if grammplot == 1
    gramm_contribution(SPM)
end