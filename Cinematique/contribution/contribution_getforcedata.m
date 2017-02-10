%   Description: get the index where the hand touch the force sensor (start) and leave the handle (end)
%   Output: gives starting and ending point of the trial
%   Functions: uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
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
plotforce   = 0;
saveresult  = 1;

%% Sujets
alias.sujet = sujets_valides;

for isujet = length(alias.sujet) : -1 : 1
    disp(['Traitement de ' cell2mat(alias.sujet(isujet)) ' (' num2str(length(alias.sujet) - isujet) ' sur ' num2str(length(alias.sujet)) ')'])
    %% Chemins
    path.raw      = ['\\10.89.24.15\f\Data\Shoulder\RAW\' cell2mat(alias.sujet(isujet)) 'd\trials\'];
    path.savepath = ['\\10.89.24.15\e\Projet_Reconstructions\DATA\Romain\' cell2mat(alias.sujet(isujet)) 'd\forceindex\'];
    
    %% noms des fichiers c3d
    C3dfiles   = dir([path.raw '*.c3d']);
    
    %% premier itération
    iter = 1;
    
    %% Ouvertures des c3d analogiques (EMG & Force)
    for     i  = length(C3dfiles) : -1 : 1
        FileName    = [path.raw C3dfiles(i).name];
        btkc3d      = btkReadAcquisition(FileName);
        btkanalog   = btkGetAnalogs(btkc3d);
        
        freq_analog = btkGetAnalogFrequency(btkc3d);
        freq_camera = btkGetPointFrequency(btkc3d);
        %% Interface pour sélectionner le nom des channels de force
        while(true)
            %% Boucle pour le premier essai
            switch iter
                case 1
                    freq_analog = btkGetAnalogFrequency(btkc3d);
                    freq_camera = btkGetPointFrequency(btkc3d);
                    matrixetal=[15.7377 -178.4176 172.9822 7.6998 -192.7411 174.1840;
                        208.3629 -109.1685 -110.3583  209.3269 -104.9032 -103.5278;
                        227.6774 222.8613 219.1087 234.3732 217.1453 221.2831;
                        5.6472 -0.7266 -0.3242 5.4650 -8.9705 -8.4179;
                        5.7700 6.7466 -6.9682 -4.1899 1.5741 -2.4571;
                        -1.2722 1.6912 -3.0543 5.1092 -5.6222 3.3049];
                    
                    fields     = fieldnames(btkanalog);
                    channels   = {'Voltage_1','Voltage_2','Voltage_3','Voltage_4','Voltage_5','Voltage_6'};
                    [oldlabel, handles] = GUI_renameforce(fields, channels);
                    waitfor(handles(1));
            end
            
            %% Si il n'y a pas de channel correspondant, relance le GUI
            %         matches  = strfind(fieldnames(btkanalog),oldlabel{1,1});
            if sum(strcmp(fieldnames(btkanalog),oldlabel{1,1})) ~= 0
                iter = 2;
                break
            else
                iter = 1;
            end
        end
        %% Obtenir la force brute
        for f = 1 : length(oldlabel)
            Force_Raw(:,f) = getfield(btkanalog,char(oldlabel{1,f}));
        end
        %% Étalonnage
        Force_eta= Force_Raw * matrixetal';
        
        %% Rebase
        Force_rebase = [];
        for j =1:6
            Force_rebase(:,j) = Force_eta(:,j)-mean(Force_eta(1:100,j));
        end
        % Filtre Butterworth
        [B,A]      = butter(4,10/100);
        Force_filt = filtfilt(B,A,Force_rebase(:,1:3));
        
        % Norme de la force
        Force_norm = sqrt(sum(Force_filt.^2,2));
        
        %% Détection de la prise (>5 N)
        % Seuil (en N)
        threshold =  5;
        
        % Méthode 1:
        %     index     = find(Force_norm(2:end-1000) > threshold);
        
        % Méthode 2 (requiert image processing toolbox):
        aboveThreshold = (Force_norm > threshold);
        spanLocs       = bwlabel(aboveThreshold);                 %identify contiguous ones
        spanLength     = regionprops(spanLocs, 'area');           %length of each span
        spanLength     = [ spanLength.Area];
        goodSpans      = find(spanLength>=1000);                  %get only spans of 5+ points
        index          = find(ismember(spanLocs, goodSpans));     %indices of these spans
        
        % Sauvegarde des index
        forceindex{i,1} = (index(1)*freq_camera)/freq_analog;
        forceindex{i,2} = (index(end)*freq_camera)/freq_analog;
        forceindex{i,3} = FileName(58:end-4);
        
        % Calcul du temps mit pour réaliser l'essai
        forceindex{i,4} = (forceindex{i,2} - forceindex{i,1})/freq_camera;
        
        if plotforce == 1
            figure
            plot(Force_norm, 'linewidth',2)
            vline([index(1) index(end)],{'g','r'},{'Début','Fin'})
            title(C3dfiles(i).name)
        end
        clearvars FileName btkc3d btkanalog Force_Raw Force_eta Force_rebase Force_filt Force_norm index
    end
    
    %% Sauvegarde des résultats
    if saveresult == 1
        if ~exist(path.savepath, 'file')
            mkdir(path.savepath);
        end
        save([path.savepath cell2mat(alias.sujet(isujet)) '_forceindex.mat'],'forceindex')
    end
end