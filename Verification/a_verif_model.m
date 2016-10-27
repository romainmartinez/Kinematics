%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ____                       _         __  __            _   _                  %
% |  _ \ ___  _ __ ___   __ _(_)_ __   |  \/  | __ _ _ __| |_(_)_ __   ___ ____  %
% | |_) / _ \| '_ ` _ \ / _` | | '_ \  | |\/| |/ _` | '__| __| | '_ \ / _ \_  /  %
% |  _ < (_) | | | | | | (_| | | | | | | |  | | (_| | |  | |_| | | | |  __// /   % 
% |_| \_\___/|_| |_| |_|\__,_|_|_| |_| |_|  |_|\__,_|_|   \__|_|_| |_|\___/___|  %
%                                                                                %  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            clc; clear; close all 
%% Informations sur le sujet
sujet = 'DavO';

%% Chargement des fonctions
    if isempty(strfind(path, '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'))
        % Librairie S2M
            loadS2MLib;
        % Fonctions perso
            addpath(genpath('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'));
    end
DirModels = ['\\10.89.24.15\f\Data\Shoulder\Lib\IRSST_' sujet 'd\Model_2\'];
path.model = [DirModels 'Model.s2mMod'];

%% Alias
    % modele_dynamique
modele_dynamique       = S2M_rbdl('new', path.model);
    % DDL
alias.nDof             = S2M_rbdl('nDof', modele_dynamique);
    % Marqueurs
alias.nTag             = S2M_rbdl('nTags', modele_dynamique);
alias.nRoot            = S2M_rbdl('nRoot', modele_dynamique);
alias.nMus             = S2M_rbdl('nmuscles', modele_dynamique);
    % Segments
alias.nBody            = S2M_rbdl('nBody', modele_dynamique);

%% Animation modèle
h = S2M_rbdl_reader(path.model);