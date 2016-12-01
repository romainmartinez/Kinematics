%   Description:
%       KIN6839_comparaison is used to compare inverse kinematics results
%       from RBDL, OpenSim and Anybody
%   Output:
%       KIN6839_comparaison gives plots to compare those models
%   Functions:
%       KIN6839_comparaison uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%   Date:    29-Nov-2016; Last revision: 30-Nov-2016
%_____________________________________________________________________________

clear all; close all; clc

%% Chargement des fonctions
if isempty(strfind(path, '\\10.89.24.15\e\Librairies\S2M_Lib\'))
    % Librairie S2M
    loadS2MLib;
end

% Dossier des data
Path.importPath = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\DavO\';

% Noms des fichiers data
Alias.RBDLnames = dir([Path.importPath 'RBDL\' '*.mat']);
Alias.OSnames   = dir([Path.importPath 'OpenSim\IK\' '*.mot']);
Alias.ABnames   = dir([Path.importPath 'AnyBody\' '*.txt']);

%% Chargement des données
% RBDL
RAW = load([Path.importPath 'RBDL\' Alias.RBDLnames.name]);

% OpenSim
for i = 1 : length(Alias.OSnames)
    % Data
    RAW.OpenSim(i).IK = importOSfile([Path.importPath 'OpenSim\IK\' Alias.OSnames(i).name], 8);
    % Header
    RAW.OpenSim(i).header = {'Th_rotY', 'Th_rotX', 'Th_rotZ', 'Th_transX', 'Th_transY', 'Th_transZ',...
        'SC_y','SC_z','SC_x','AC_y','AC_z','AC_x','GH_x','GH_y','GH_z','EL_x',...
        'PS_y','wrist_dev_r','wrist_flex_r'};
end

% AnyBody
for i = 1 : length(Alias.OSnames)
    % Data
    RAW.AnyBody(i).IK = importABfile([Path.importPath 'AnyBody\' Alias.ABnames(i).name]);
    % Header
    RAW.AnyBody(i).header = {'SternoClavicularProtraction', 'SternoClavicularElevation', 'SternoClavicularAxialRotation',...
        'AcromioClavicularProtraction','AcromioClavicularElevation', 'AcromioClavicularAxialRotation',...
        'GlenohumeralFlexion', 'GlenohumeralExternalRotation','GlenohumeralAbduction', 'ElbowFlexion',...
        'ElbowPronation', 'WristFlexion', 'WristAbduction'};
end

%% Ré-organisation des datas
% Sélection des DoFs
for i = 1 : length(RAW.AnyBody)
    % Conversion en degrés (RBDL et AnyBody seulement)
    RAW.AnyBody(i).IK    = rad2deg(RAW.AnyBody(i).IK);
    RAW.RBDL(i).selected = rad2deg(RAW.RBDL(i).selected);
end

x     = linspace(0,100,500);

%% AnyBody
data = []; model = []; dof = [];

for i = 1 : length(RAW.AnyBody)
selectedcolon      = 1 : 13;
correspondingcolon = 1 : 13;
data               = [data ; num2cell(RAW.AnyBody(i).IK(:,selectedcolon),1)'];
model              = [model ; cellstr(repmat('AnyBody',length(selectedcolon),1))];
dof                = [dof ; correspondingcolon'];
end

%% OpenSim
for i = 1 : length(RAW.OpenSim)
selectedcolon      = [10:17 19 18]; 
correspondingcolon = 4 : 13;
data               = [data ; num2cell(RAW.OpenSim(i).IK(:,selectedcolon),1)'];
model              = [model ; cellstr(repmat('OpenSim',length(selectedcolon),1))];
dof                = [dof ; correspondingcolon'];
end

%% RBDL
for i = 1 : length(RAW.RBDL)
selectedcolon      = [23 25 26]; 
correspondingcolon = [5 10 11];
data               = [data ; num2cell(RAW.RBDL(i).selected(:,selectedcolon),1)'];
model              = [model ; cellstr(repmat('RBDL',length(selectedcolon),1))];
dof                = [dof ; correspondingcolon'];
end

for i = 1 : length(data)
    nbframe = 500;
    data{i,1} = ScaleTime(data{i,1}, 1, length(data{i,1}), 500);
end
%% Plot
figure('unit','normalized','Position',[0 0 1 1]);
%% Wrist
g(1,1)=gramm('x',x,'y',data,'color',model,'subset',dof == 13);
g(1,1).geom_line();
g(1,1).set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g(1,1).set_title('Comparison of wrist abduction');

g(2,1)=gramm('x',x,'y',data,'color',model,'subset',dof == 12);
g(2,1).geom_line();
g(2,1).set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g(2,1).set_title('Comparison of wrist flexion');

g.draw();
%% Elbow
figure('unit','normalized','Position',[0 0 1 1]);
g(1,1)=gramm('x',x,'y',data,'color',model,'subset',dof == 11);
g(1,1).geom_line();
g(1,1).set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g(1,1).set_title('Comparison of elbow pronation');

g(2,1)=gramm('x',x,'y',data,'color',model,'subset',dof == 10);
g(2,1).geom_line();
g(2,1).set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g(2,1).set_title('Comparison of elbow flexion');

g.draw();
%% GH
figure('unit','normalized','Position',[0 0 1 1]);
g(1,1)=gramm('x',x,'y',data,'color',model,'subset',dof == 9);
g(1,1).geom_line();
g(1,1).set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g(1,1).set_title('Comparison of glenohumeral flexion');

g(2,1)=gramm('x',x,'y',data,'color',model,'subset',dof == 8);
g(2,1).geom_line();
g(2,1).set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g(2,1).set_title('Comparison of glenohumeral external rotation');

g(3,1)=gramm('x',x,'y',data,'color',model,'subset',dof == 7);
g(3,1).geom_line();
g(3,1).set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g(3,1).set_title('Comparison of glenohumeral flexion');

g.draw();

%% AC
figure('unit','normalized','Position',[0 0 1 1]);
g(1,1)=gramm('x',x,'y',data,'color',model,'subset',dof == 6);
g(1,1).geom_line();
g(1,1).set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g(1,1).set_title('Comparison of acromioclavicular axial rotation');

g(2,1)=gramm('x',x,'y',data,'color',model,'subset',dof == 5);
g(2,1).geom_line();
g(2,1).set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g(2,1).set_title('Comparison of acromioclavicular elevation');

g(3,1)=gramm('x',x,'y',data,'color',model,'subset',dof == 4);
g(3,1).geom_line();
g(3,1).set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g(3,1).set_title('Comparison of acromioclavicular protraction');

g.draw();

%% ST
figure('unit','normalized','Position',[0 0 1 1]);
g(1,1)=gramm('x',x,'y',data,'color',model,'subset',dof == 3);
g(1,1).geom_line();
g(1,1).set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g(1,1).set_title('Comparison of sternoclavicular axial rotation');

g(2,1)=gramm('x',x,'y',data,'color',model,'subset',dof == 2);
g(2,1).geom_line();
g(2,1).set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g(2,1).set_title('Comparison of sternoclavicular elevation');

g(3,1)=gramm('x',x,'y',data,'color',model,'subset',dof == 1);
g(3,1).geom_line();
g(3,1).set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g(3,1).set_title('Comparison of sternoclavicular protraction');

g.draw();
%%
% AES
g(1)=gramm('x',x,'y',data,'color',model,'subset',dof ~= 1 & dof ~= 2 & dof ~= 3 & dof ~= 4 & dof ~= 5 & dof ~= 6);
% g(1,1)=gramm('x',x,'y',data,'color',model,'subset',dof == 13);

% Geom
g(1).geom_line();
% g(1).stat_smooth()
% g(1).stat_summary('type','std');

% Facet
g(1).facet_grid([],dof);

% Customization of gramm figures
g.set_names('x','Normalized time (% of trial)','y','Amplitude of movement (degrees)','color','Model used');
g.set_title('Comparison of elbow flexion');


g.draw();

%% Plot
% Couleurs
colors = distinguishable_colors(28);

%% OpenSim    
for i = 1 : size(RAW.OpenSim(trial).IK,2)
plot(RAW.OpenSim(trial).IK(:,i),...
        'Linewidth',2,...
        'Color', colors(i,:)); 
hold on
end
title('OpenSim')
legend(RAW.OpenSim(trial).header)

%% AnyBody
figure

for i = 1 : size(Data.AnyBody(trial).IK,2)
plot(Data.AnyBody(trial).IK(:,i),...
        'Linewidth',2,...
        'Color', colors(i,:)); 
hold on
end
title('AnyBody')
legend(Data.AnyBody(trial).header)

%% RBDL
trial=1;

figure
for i = 1 : size(RAW.RBDL(trial).selected,2)
plot(RAW.RBDL(trial).selected(:,i),...
        'Linewidth',2,...
        'Color', colors(i,:)); 
hold on
end
title('RBDL')
legend(RAW.RBDL(trial).header)
