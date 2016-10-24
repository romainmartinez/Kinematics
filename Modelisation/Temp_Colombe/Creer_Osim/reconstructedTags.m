%% CREATION DU .TRC ET FICHIERS SCALING

%%% input  Q from reconstruction
%%% output - marker coordinates in global reference system
%%%		   - cut trials
%%%		   - conf IK
%%%		   - conf IK static

clear
close all
clc

%% path and trial info

subject    = 'Alexandra';
importPath = 'F:\Data\Shoulder\RAW\ergoAlexandrad\MODEL4\'; 

AnatoTrc = 1; % export Anato Trc
IKstat   = 1; % export IK static conf file

if IKstat
	importPath = 'E:\Projet_Yoann\muscle_contribution_box_acceleration\fileOpenSim';
	exportPath = 'E:\Bureau\Colombe\';
	GenerateOpenSimIKFileStat(importPath,exportPath,subject);
end


if AnatoTrc
	
	anatoCsvPath = 'F:\Data\Shoulder\RAW\ergoAlexandrad\MODEL4\ergoAlexandrad0.csv';
	
	anatoCoord = dlmread(anatoCsvPath,',',5,0);
	
 	anatoCoordOpenSim=zeros(size(anatoCoord,1),size(anatoCoord,2)-2);

    anatoCoordOpenSim(:,1:3:end) = 	anatoCoord(:,3:3:end);	
	anatoCoordOpenSim(:,2:3:end) = 	anatoCoord(:,5:3:end);	
	anatoCoordOpenSim(:,3:3:end) = 	-anatoCoord(:,4:3:end);

	%% tags name
	
	fid = fopen(anatoCsvPath);
	fileCsv = textscan(fid,'%s');
	fclose(fid);
	
	tagsLine = fileCsv{1}(3,:);
	tagsLine{1}(1:2) = '*';
	comaInd = (strfind(tagsLine{1},','))';
	tagsLine{1}(comaInd(2:3:end))='*';
	tagsLine{1}(comaInd(3:3:end))='*';
	
	firstLetterInd = (strfind(tagsLine{1},':')+1)';
	endLetterInd = (strfind(tagsLine{1},',')-1)';
	
	for i=1:length(firstLetterInd)
        tagsAnato{i,1} = tagsLine{1}(firstLetterInd(i):endLetterInd(i));
    end
    
    confTrcAnato.DataRate   = 300; 
	confTrcAnato.CameraRate = 300;
	confTrcAnato.Units      = 'mm'; 
	confTrcAnato.OrigDataRate =  300 ;
	confTrcAnato.OrigDataStartFrame =  1  ;
	confTrcAnato.headers = ['Frame#';'Time';tagsAnato];
	confTrcAnato.NumFrames =  size(anatoCoordOpenSim,1);
	confTrcAnato.NumMarkers =  (size(anatoCoordOpenSim,2))/3;
	confTrcAnato.OrigNumFrames =  size(anatoCoordOpenSim,1);
	confTrcAnato.frame=confTrcAnato.OrigDataStartFrame : confTrcAnato.NumFrames;
	confTrcAnato.time = confTrcAnato.frame/confTrcAnato.DataRate;
    
    exportPathAnato = 'E:\Bureau\Colombe';
	
	GenerateOpenSimTrcFile(exportPathAnato,'Anato',confTrcAnato,anatoCoordOpenSim,subject)
	
end

keyboard;

%% create conf SO file

if SOconf
	importPath = 'E:\Projet_Yoann\muscle_contribution_box_acceleration\fileOpenSim';
	exportPath = ['E:\Projet_Yoann\muscle_contribution_box_acceleration\sujets\' subject 'd\new\' trialName];

	importPathCopy = 'E:/Projet_Yoann/muscle_contribution_box_acceleration/fileOpenSim';
	exportPathCopy = ['E:/Projet_Yoann/muscle_contribution_box_acceleration/sujets/' subject 'd/new/' trialName];
	copyfile([importPathCopy '/Conf_SO_Actuators.xml'],[exportPathCopy '/Conf_SO_Actuators.xml'])
	
	impID = dlmread(['E:\Projet_Yoann\openSim\RunningAnalysis\' subject 'd\opensimFile\' trialName '\Results_IK.mot'],...
		'\t', 11,0);
	
	tStart = impID(1,1);
	tEnd = impID(end,1);
	
	GenerateOpenSimSOFile(importPath,exportPath,tStart,tEnd,subject,trialName)
end

if JRconf
	importPath = 'E:\Projet_Yoann\muscle_contribution_box_acceleration\fileOpenSim';
	exportPath = ['E:\Projet_Yoann\muscle_contribution_box_acceleration\sujets\' subject 'd\new\' trialName];
	
	impID = dlmread(['E:\Projet_Yoann\openSim\RunningAnalysis\' subject 'd\opensimFile\' trialName '\Results_IK.mot'],...
		'\t', 11,0);
	
	tStart = impID(1,1);
	tEnd = impID(end,1);
	
	GenerateOpenSimJRFile(importPath,exportPath,tStart,tEnd,subject)
end


