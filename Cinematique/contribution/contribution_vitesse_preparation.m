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
saveresults = 1;
model       = 2.1;

%% Dossiers
path.datapath   = '\\10.89.24.15\e\\Projet_IRSST_LeverCaisse\ElaboratedData\matrices\cinematique\';
path.exportpath = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\matrices\vitesse\';
alias.matname = dir([path.datapath '*mat']);

%% Info sur le sujets et le model
alias.sujet = sujets_valides;
[segmentMarkers, segmentDoF] = segment_RBDL(round(model));
segmentDoF = struct2cell(segmentDoF);

for isujet = 1 %length(alias.sujet) : -1 : 1
    
    disp(['Traitement de: ' alias.sujet{isujet} ' (' num2str(length(alias.sujet) - isujet+1) ' sur ' num2str(length(alias.sujet)) ')'])
    
    % Open model
    Path.DirModels  = ['\\10.89.24.15\f\Data\Shoulder\Lib\' alias.sujet{isujet} 'd\Model_' num2str(round(model)) '\' 'Model.s2mMod'];
    alias.model = S2M_rbdl('new',Path.DirModels);
    
    % load data
    load([path.datapath alias.sujet{isujet} '.mat']);data = temp;clearvars temp
    
    for itrial = length(data) : - 1 : 1
        disp([9 'essai: ' num2str(length(data)-itrial+1) ' sur ' num2str(length(data))])
        
        for iframe = length(data(itrial).Qdata.Q2) : -1 : 1
             TJi = S2M_rbdl('TagsJacobian', alias.model, data(itrial).Qdata.Q2(:,iframe));
             
            for isegment = 4 : -1 : 1
                % jacobian for this frame
                
                % contribution of each segment to the vertical velocity of marker 39
                % 43 + 43 + 39 --> x + y + z of marker 39
                contrib(isegment,iframe) = multiprod(TJi(43+43+39,segmentDoF{isegment}),...
                    data(itrial).Qdata.QDOT2(segmentDoF{isegment},iframe));
            end
            contrib(5,iframe) = TJi(43+43+39,:)*data(itrial).Qdata.QDOT2(:,iframe);
        end
        % low pass 15 Hz
        data(itrial).deltahand = lpfilter(contrib(1,round(data(itrial).start):round(data(itrial).end))', 15, 100);
        data(itrial).deltaGH   = lpfilter(contrib(2,round(data(itrial).start):round(data(itrial).end))', 15, 100);
        data(itrial).deltaSCAC = lpfilter(contrib(3,round(data(itrial).start):round(data(itrial).end))', 15, 100);
        data(itrial).deltaRoB  = lpfilter(contrib(4,round(data(itrial).start):round(data(itrial).end))', 15, 100);
        data(itrial).velocity  = lpfilter(contrib(5,round(data(itrial).start):round(data(itrial).end))', 15, 100);
        clearvars contrib
    end
    
    % close model
    S2M_rbdl('delete', alias.model);
    
    % save matrix
    if saveresults == 1
        save([path.exportpath alias.sujet{isujet} '.mat'],'data')
    end
    clearvars data TJi 
end

%% Zone de test
tata = 1
tp=data(tata).deltaRoB;
plot(tp) ; hold on
tp=tp+data(tata).deltaSCAC;
plot(tp) ;
tp=tp+data(tata).deltaGH;
plot(tp) ;
tp=tp+data(tata).deltahand;
plot(tp) ;

figure
tp=data(tata).deltaRoB;
plot(tp) ; hold on
tp=data(tata).deltaSCAC;
plot(tp) ;
tp=data(tata).deltaGH;
plot(tp) ;
tp=data(tata).deltahand;
plot(tp) ;
tp=data(tata).velocity; % la somme des autres doit être égal à elle
plot(tp) ;
