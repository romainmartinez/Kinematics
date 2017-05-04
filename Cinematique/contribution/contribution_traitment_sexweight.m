%   Description: used to compute the contribution of each articulation to the height
%       - test: ANOVA 2-way
%       - factors: sex (men or women) | weight (12 kg vs 6 kg)
%
%   Output:  gives SPM output and graph
%   Functions: uses functions present in //10.89.24.15/e/Project_IRSST_LeverCaisse/Codes/Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%_____________________________________________________________________________

clear variables; close all; clc

path2 = load_functions('linux', 'Kinematics/Cinematique');

% Switch
variable    =  'hauteur';           % 'vitesse' ou 'hauteur'
verif       =   1;                  % 0 or 1
grammplot   =   1;                  % 0 or 1
exporter    =   1;                  % 0 or 1

% Path
path2.Datapath = [path2.E '/Projet_IRSST_LeverCaisse/ElaboratedData/matrices/' variable '/'];
path2.exportpath = [path2.E '/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_articulation/SPM/'];
alias.matname = dir([path2.Datapath '*mat']);

% load data
for i = length(alias.matname) : -1 : 1
    RAW(i) = load([path2.Datapath alias.matname(i).name]);      % load data
    [RAW(i).temp.sujet] = deal(alias.matname(i).name(1:end-4)); % subject name
    [RAW(i).temp.nsujet] = deal(i);                             % subject number
    [RAW(i).temp([RAW(i).temp.sexe] == 'H').sexe] = deal(1);    % men
    [RAW(i).temp([RAW(i).temp.sexe] == 'F').sexe] = deal(2);    % women
end
% big structure of data
bigstruct  = struct2array(RAW);

% select data
bigstruct = select_data(bigstruct, 2);

% number of frames needed (interpolation)
nbframe = 100;

% Factors
SPM.sex = vertcat(bigstruct(:).sexe)';
SPM.weight = vertcat(bigstruct(:).poids)';
SPM.duration = vertcat(bigstruct(:).time)';
SPM.subject = vertcat(bigstruct(:).nsujet)';
SPM.time  = linspace(0,100,nbframe); % Vecteur X (time in %)

% Transform dataframe into GRAMM & SPM friendly
for i = 1 : length(bigstruct)
    for idelta = {'deltahand', 'deltaGH', 'deltaSCAC', 'deltaRoB'}
        % low-pass filter 15Hz
        bigstruct(i).(char(idelta)) = lpfilter(bigstruct(i).(char(idelta)), 15, 100);
        % interpolation
        SPM.(char(idelta))(i,:) = ScaleTime(bigstruct(i).(char(idelta)), 1, length(bigstruct(i).(char(idelta))), nbframe);
    end
end

if verif
    selected = gramm_contribution(SPM, 'verif');
    export_selected = [cellstr(str2mat(bigstruct(selected).sujet)) cellstr(str2mat(bigstruct(selected).trialname))];
    cell2csv('verif.csv', export_selected, ',');
    
end

if grammplot
    gramm_contribution(SPM);
end

% Number of men & women
isbalanced(SPM.sex)

% SPM
for idelta = 4 : -1 : 1 % delta
    % variable
    [SPM] = selectSPMvariable(SPM,idelta);
    % SPM analysis
    [result(idelta)] = SPM_contribution(SPM, idelta);
    
    %     [result(idelta).anova,result(idelta).interaction] = SPM_contribution(...
    %         SPM.comp,SPM.sexe,SPM.poids,SPM.sujet,idelta,SPM.duree,correctbonf);
end

% Export results (csv)
if exporter
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