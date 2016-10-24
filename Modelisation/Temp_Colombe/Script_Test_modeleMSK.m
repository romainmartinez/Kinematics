%% TEST MODELE YOANNN OPENSIM

clc,
clear,
% close all,

%% Dossiers

DirLib    = '/home/collaboration/mnt/E';
DirModels = '/home/clientbd8/Documents/muscod/Colombe_devel/ModelesS2M/';%'/home/collaboration/mnt/Ponts/Colombe/Projet_These/Test_modeleMSK/Modeles_S2MTest/';

%% Chemins d'accès

addpath('/home/collaboration/mnt/Ponts/Colombe/Projet_These/Test_modeleMSK/Functions_S2M')
addpath('/home/collaboration/mnt/Ponts/Colombe/Projet_These/Test_modeleMSK/Functions_Generate_Files')
addpath('/home/collaboration/mnt/Ponts/Colombe/Projet_These/Test_modeleMSK/Modeles_OpenSim')

run('/home/clientbd8/Documents/S2M_Lib_ColombeDevel/loadS2MLib_pwd.m');

%% Ouverture du modèle RBDL et alias associés

%Modèle RBDL
path.model = [DirModels 'Essai_Mouv.s2mMod'];

%Alias
modele_dynamique       = S2M_rbdl('new', path.model);
alias.nDof             = S2M_rbdl('nDof', modele_dynamique); %DDL
alias.nTag             = S2M_rbdl('nTags', modele_dynamique); %Marqueurs
alias.nRoot            = S2M_rbdl('nRoot', modele_dynamique);
alias.nMus             = S2M_rbdl('nmuscles', modele_dynamique);
alias.nBody            = S2M_rbdl('nBody', modele_dynamique); %Segments

%% Animation modèle

h = S2M_rbdl_reader_coco(path.model);

%% Matrices

%Cinématique
% Q = h.getQ;
% Q = [Q , h.getQ];
% % load('QQ');

%Butées articulaires
Q=[];
Qmin = -ones(1,alias.nDof)*0.2;%[];
Qmax =  ones(1,alias.nDof)*0.3;%[];
 

% Qmin=[];
% %thorax
% Qmin(1) = -0.400000004249 ;
% Qmin(2) = -1.57 ;
% Qmin(3) = -0.409999995719 ;
% Qmin(4:6) = -25 ;
% %clavicule
% Qmin(7) = -0.5 ;
% Qmin(8) = -1.020926 ;
% Qmin(9) = -0.6 ;
% %scapula
% Qmin(10) = -1 ;
% Qmin(11:12) = -0.5 ;
% %humerus
% Qmin(13) = -2.5 ;
% Qmin(14) = -3 ;
% Qmin(15) = -2.5 ;
% Qmin(16) = 0.5;
% %ulna
% Qmin(17) = 0 ;
% %radius
% Qmin(18) = -2.5 ;
% %hand
% Qmin(19:21) = -3.14;
% 
% Qmax=[];
% %thorax
% Qmax(1) = 0.400000004249;
% Qmax(2) = 1.57 ;
% Qmax(3) = 0.40000008498;
% Qmax(4:6) = 25;
% %clavicule
% Qmax(7) = 1.6;
% Qmax(8) = 1.2;
% Qmax(9) = 1.5;
% %scapula
% Qmax(10:12) = 1.5;
% %humerus
% Qmax(13) = 0.5;
% Qmax(14) = 3;
% Qmax(15) = 0.5;
% Qmax(16) = 0.5;
% %ulna
% Qmax(17) =3.140000005741;
% %radius
% Qmax(18) =  2.500000008498;
% %hand
% Qmax(19:21) = 3.14;

for i=1:alias.nDof
    Q(i,:)= linspace(Qmin(i),Qmax(i),100);
end

%Rotation zz pour l'humerus
Q(15,:) = -Q(13,:);

%Temps
FrameRate = 100;
time = (0:size(Q,2)-1)/FrameRate;

%Conversion radians degrés
r2d = 180/pi;
Conve = [r2d  r2d  r2d 1 1 1,... thorax
        -r2d -r2d  r2d, ...clavicle
        -r2d -r2d  r2d,...scapula
         r2d  r2d  r2d,...humerus
         r2d  ,...ulna
        -r2d  ,...radius
        -r2d  r2d -r2d];

Conve = ones(size(Q,2),1)*Conve;
    
%     Conve = [ones(3,size(Q,2))*r2d ; ... 1...3
%         ones(3,size(Q,2)); ...4...6
%         ones(11,size(Q,2))*r2d; ...7..17
%        -ones(1,size(Q,2))*r2d;...18
%         ones(2,size(Q,2))*r2d];

%Table Kin
Kin = [time ; Q([1:14 16:alias.nDof],:).*Conve'];

%Marqueurs
Tags = S2M_rbdl('Tags', modele_dynamique, Q);
% Tags = [Tags(:,[1:10 14:end],:) Tags(:,11:13,:)]; %3 marqueurs de la glène sont remis à la fin

[~,nb_mark,nb_Frame] = size(Tags);

%% Creation du fichier .mot

% FileMot = [DirModels, 'EssaiMvt.mot'];

confMot.header = {'Coordinates'; 'version=1'; sprintf('nRows=%d',nb_Frame); sprintf('nColumns=%d',alias.nDof); 'inDegrees=yes';...
                  'Units are S.I. units (second, meters, Newtons, ...)';...
                  'Angles are in degrees'};

confMot.endheader = {'endheader'}; 

confMot.nameddl = {'time',...
                 'Th_rotX', 'Th_rotY', 'Th_rotZ', 'Th_transX', 'Th_transY',	'Th_transZ',...
                 'Clav_rotZ_right', 'Clav_rotY_right', 'Clav_rotX_right',...
                 'Scap_rotZ_right',	'Scap_rotY_right', 'Scap_rotX_right',...
                 'Hum_rotZ_right', 'Hum_rotY_right', 'Hum_rotZZ_right',...
                 'Elb_flex_right', 'Elb_ProSup_right',...
                 'wrist_dev_r', 'wrist_flex_r'}; 

GenerateOpenSimMotFile(DirModels,confMot,Kin);

%% Creation du fichier .trc

confTrc.header1 = {'PathFileType' , '4' , '(X/Y/Z)', 'TestModele.trc'} ;

confTrc.header2 = {'DataRate' , 'CameraRate' , 'NumFrames' , 'NumMarkers' , 'Units' , 'OrigDataRate' , 'OrigDataStartFrame' , 'OrigNumFrames'} ;

confTrc.header3 = {num2str(FrameRate) , num2str(FrameRate) , num2str(nb_Frame), num2str(nb_mark) , 'm' , num2str(FrameRate) , '0', num2str((nb_Frame-1)/FrameRate)} ;

confTrc.header4 = {'Frame#','s'} ;
for i=1:nb_mark
    confTrc.header4 = [confTrc.header4 sprintf('x%d',i) sprintf('y%d',i) sprintf('z%d',i)];
end

% MarkerNames     = {'STER', 'XIPH', 'T10', 'C7', 'CLAV_SC', 'CLAV_post', 'CLAV_AC', 'SCAP_IA', 'SCAP_RS', 'SCAP_SA', 'ACRO_tip', 'EPICl', 'EPICm', 'STYLr', 'STYLu', 'MEDH', 'INDEX', 'LATH', 'LASTC', 'infGlen', 'antGlen', 'postGlen'};
MarkerNames     = {'STER', 'XIPH', 'T10', 'C7', 'CLAV_SC', 'CLAV_post', 'CLAV_AC','SCAP_IA', 'SCAP_RS', 'SCAP_SA', 'ACRO_tip'};
confTrc.markers = [ {'Frame#' , 'Time' } , MarkerNames ];

GenerateOpenSimTrcFile(DirModels,confTrc,Tags,time);

%% Longueurs musculaires

l = S2M_rbdl('muscleLength', modele_dynamique, Q);

%% Fermeture

S2M_rbdl('delete', modele_dynamique);
