%   Description: used to replace a missing marker with random numbers
%   Output:  gives clean c3d
%   Functions: uses functions present in //10.89.24.15/e/Project_IRSST_LeverCaisse/Codes/Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%_____________________________________________________________________________

clear variables; close all; clc

path2 = load_functions('linux', 'Kinematics/Cinematique');

%% Caract�ristique
%Nom du sujet
alias.subject = 'YosC';

% Dossier des essais
path.folderPath = [path2.F '/Data/Shoulder/RAW/IRSST_' alias.subject 'd/trials/'];

% noms des fichiers c3d
alias.C3dfiles   = dir([path.folderPath '*.c3d']);

% Marqueur manquant
missed = 'Yosra_ARMm';

%% Chargement des donn�es

for i = 1 : length(alias.C3dfiles)
    % Chargement des donn�es
    Filename   = [path.folderPath alias.C3dfiles(i).name];
    fprintf('Traitement de %d (%s)/n', i, alias.C3dfiles(i).name);
    btkc3d      = btkReadAcquisition(Filename);
    btkmarker   = btkGetMarkers(btkc3d);
    pointlabel = missed;
    
    try
        btkAppendPoint(btkc3d, 'marker', pointlabel, repmat([0.1 0.1 0.1], length(btkmarker.Yosra_ASISr),1))
    catch
        btkSetPoint(btkc3d, pointlabel, repmat([0.1 0.1 0.1], length(btkmarker.Yosra_ASISr),1))
    end
    btkWriteAcquisition(btkc3d, Filename)
end
