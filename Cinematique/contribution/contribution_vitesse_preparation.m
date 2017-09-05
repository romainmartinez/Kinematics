%   Description: used to compute the contribution of each articulation to the acceleration
%   Output: gives matrix for input in SPM1D and GRAMM
%   Functions: uses functions present in //10.89.24.15/e/Project_IRSST_LeverCaisse/Codes/Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%_____________________________________________________________________________

clear variables; close all; clc

path2 = load_functions('linux', 'Kinematics/Cinematique');

%% Interrupteurs
saveresults = 0;
model       = 2.1;
outlier     = 1;

%% Dossiers
path2.datapath   = [path2.E '/Projet_IRSST_LeverCaisse/ElaboratedData/matrices/cinematique/'];
path2.exportpath = [path2.E '/Projet_IRSST_LeverCaisse/ElaboratedData/matrices/vitesse/'];
alias.matname = dir([path2.datapath '*mat']);

%% Info sur le sujets et le model
alias.sujet = IRSST_participants('IRSST');
[segmentMarkers, segmentDoF] = segment_RBDL(round(model));
segmentDoF = struct2cell(segmentDoF);

for isujet = length(alias.sujet) : -1 : 1
    
    disp(['Traitement de: ' alias.sujet{isujet} ' (' num2str(length(alias.sujet) - isujet+1) ' sur ' num2str(length(alias.sujet)) ')'])
    
    % Open model
    path2.DirModels  = [path2.F '/Data/Shoulder/Lib/' alias.sujet{isujet} 'd/Model_' num2str(round(model)) '/' 'Model.s2mMod'];
    alias.model = S2M_rbdl('new',path2.DirModels);
    
    % load data
    load([path2.datapath alias.sujet{isujet} '.mat']);
    
    for itrial = length(temp) : - 1 : 1
        disp([9 'essai: ' num2str(length(temp)-itrial+1) ' sur ' num2str(length(temp))])
        
        for iframe = length(temp(itrial).Qdata.Q2) : -1 : 1
            TJi = S2M_rbdl('TagsJacobian', alias.model, temp(itrial).Qdata.Q2(:,iframe));
            
            for isegment = 4 : -1 : 1
                % jacobian for this frame
                % contribution of each segment to the vertical velocity of marker 39
                % 43 + 43 + 39 --> x + y + z of marker 39
                contrib(isegment,iframe) = multiprod(TJi(43+43+39,segmentDoF{isegment}),...
                    temp(itrial).Qdata.QDOT2(segmentDoF{isegment},iframe));
            end
            contrib(5,iframe) = TJi(43+43+39,:)*temp(itrial).Qdata.QDOT2(:,iframe);
        end
        
        % low pass 15 Hz
        temp(itrial).deltahand = lpfilter(contrib(1,round(temp(itrial).start):round(temp(itrial).end))', 15, 100);
        temp(itrial).deltaGH   = lpfilter(contrib(2,round(temp(itrial).start):round(temp(itrial).end))', 15, 100);
        temp(itrial).deltaSCAC = lpfilter(contrib(3,round(temp(itrial).start):round(temp(itrial).end))', 15, 100);
        temp(itrial).deltaRoB  = lpfilter(contrib(4,round(temp(itrial).start):round(temp(itrial).end))', 15, 100);
        temp(itrial).velocity  = lpfilter(contrib(5,round(temp(itrial).start):round(temp(itrial).end))', 15, 100);
        clearvars contrib
        
        if outlier == 1
            temp(itrial).deltahand = medfilt1(hampel(temp(itrial).deltahand,20,0.5),10);
            temp(itrial).deltaGH   = medfilt1(hampel(temp(itrial).deltaGH,20,0.5),10);
            temp(itrial).deltaSCAC = medfilt1(hampel(temp(itrial).deltaSCAC,20,0.5),10);
            temp(itrial).deltaRoB  = medfilt1(hampel(temp(itrial).deltaRoB,20,0.5),10);
            temp(itrial).velocity  = medfilt1(hampel(temp(itrial).velocity,20,0.5),10);
            % xi = medfilt1(xi,10);
        end
    end
    
    % close model
    S2M_rbdl('delete', alias.model);
    
    % save matrix
    if saveresults == 1
        temp = rmfield(temp, {'Qdata'});
        save([path2.exportpath alias.sujet{isujet} '.mat'],'temp')
    end
    %     clearvars temp TJi
end

% %% Zone de test
% tata = 4
% tp=temp(tata).deltaRoB;
% plot(tp) ; hold on
% tp=tp+temp(tata).deltaSCAC;
% plot(tp) ;
% tp=tp+temp(tata).deltaGH;
% plot(tp) ;
% tp=tp+temp(tata).deltahand;
% plot(tp) ;
%
% figure
% tp=temp(tata).deltaRoB;
% plot(tp) ; hold on
% tp=temp(tata).deltaSCAC;
% plot(tp) ;
% tp=temp(tata).deltaGH;
% plot(tp) ;
% tp=temp(tata).deltahand;
% plot(tp) ;
% tp=temp(tata).velocity; % la somme des autres doit �tre �gal � elle
% plot(tp) ;
%
% %%
% xi = [temp(1).deltaRoB temp(1).deltaSCAC temp(1).deltaGH temp(1).deltahand]
% subplot(2,1,1)
% plot(xi);
% xi = hampel(xi,20,0.5);
% xi = medfilt1(xi,10);
% subplot(2,1,2)
% plot(xi);
%
% for icol= size(xi,2): -1 : 1
%     xi(:,icol) = lpfilter(xi(irow,round(temp(itrial).start):round(temp(itrial).end))', 6, 100);
% end
%
% plot([temp(itrial).deltaGH])