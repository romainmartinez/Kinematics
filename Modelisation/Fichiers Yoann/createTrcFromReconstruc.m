close all
clear
clc


%% info
subject='TA';
trialName='flex2_1'; 
type = '_RegAll';
pathRawFile = ['\\134.214.26.46\d$\recherche\yoann\STA_MSK\subject\' subject '\'];


%% import IK res
IKres=importdata([pathRawFile '\results_IK\' trialName type '.mat']);

%% import initial trc
trcPathInput = [pathRawFile 'opensim\' trialName(1:4) '\' trialName '_raw.trc'];

%% data to export
newDataOpensim(:,1)=IKres.frame;
newDataOpensim(:,2)=IKres.time;
newDataOpensim(:,3:size(IKres.markerGlobalOpensim,2)+2)=IKres.markerGlobalOpensim;

%% export
properties.DataRate=300;
properties.CameraRate=300;
properties.Units='mm';
properties.OrigDataRate=300;
properties.OrigDataStartFrame=1;
properties.NumFrames=size(newDataOpensim,1);
properties.NumMarkers=size(IKres.markerGlobalOpensim,2)/3;
properties.OrigNumFrames=properties.NumFrames;

% Écrire le fichier .trc
    fidTRC = fopen([pathRawFile 'opensim\' trialName(1:4) '\' trialName type '.trc'],'w+');
    fprintf(fidTRC,'PathFileType\t4\t(X/Y/Z)\t%s\n',[pathRawFile 'opensim\' trialName(1:4) '\' trialName 'all.trc']);
    fprintf(fidTRC,'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames\n');
    fprintf(fidTRC,'%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\n', properties.DataRate,  properties.CameraRate,  properties.NumFrames,...
                      properties.NumMarkers, properties.Units, properties.OrigDataRate, properties.OrigDataStartFrame,...
                      properties.OrigNumFrames);
    fprintf(fidTRC,'Frame#\tTime\t');
    fprintf(fidTRC,'%s\t\t\t', IKres.headerAllMarkers{:}); fprintf(fidTRC,'\n');
    marknumber = repmat((1:properties.NumMarkers),[3,1]);
    fprintf(fidTRC,'\t\t'); fprintf(fidTRC,'X%d\tY%d\tZ%d\t', marknumber(:)); fprintf(fidTRC,'\n');
    for i = 1:size(newDataOpensim,1)
        fprintf(fidTRC,'%d\t',newDataOpensim(i,:));
        fprintf(fidTRC,'\n');
    end
        
    fclose(fidTRC);

