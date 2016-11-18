%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ____                       _         __  __            _   _                  %
% |  _ \ ___  _ __ ___   __ _(_)_ __   |  \/  | __ _ _ __| |_(_)_ __   ___ ____  %
% | |_) / _ \| '_ ` _ \ / _` | | '_ \  | |\/| |/ _` | '__| __| | '_ \ / _ \_  /  %
% |  _ < (_) | | | | | | (_| | | | | | | |  | | (_| | |  | |_| | | | |  __// /   %
% |_| \_\___/|_| |_| |_|\__,_|_|_| |_| |_|  |_|\__,_|_|   \__|_|_| |_|\___/___|  %
%                                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            clc; clear; close all;
%% Chargement des fonctions
    if isempty(strfind(path, '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'))
        % Librairie S2M
            loadS2MLib;
        % Fonctions perso
            addpath(genpath('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'));
    end
%% Organisation des données
    % 1) Créer un dossier 'InputData' (exemple, '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\InputData')
    % 2) Copier l'intégralité des fichiers C3D
    
%% Edition de fichiers : renommer les C3D
        run('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Kinematics\OrgData\C3D2MOtoNMS.m')

%% Interface d'acquisition (description des données
    % 1) Créer les SetupFiles suivant : 
        % a) Laboratories
        % b) MarkersProtocols
        % c) EMGsProtocols
    % Ces fichiers sont créés selon le modèle XML fourni
    % 2) Interface d'acquisition
        cd('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab\MOtoNMS\src\AcquisitionInterface')
        run('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab\MOtoNMS\src\AcquisitionInterface\mainAcquisitionInterface.m')
%% Convertir les C3D en format Matlab
        cd('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab\MOtoNMS\src\C3D2MAT_btk')
        run('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab\MOtoNMS\src\C3D2MAT_btk\C3D2MAT.m')
