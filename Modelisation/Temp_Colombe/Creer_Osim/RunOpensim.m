%%% input - kinematics trc files
%%%       - kinematics trc files
%%% output - marker coordinates in global reference system
%%%		   - cut trials
%%%		   - conf IK
%%%		   - conf IK static

clear
close all
clc

subject = 'SteB';
trialName = {'F6H1_1'};
% weight = '0kg';
importPath = 'E:\Projet_Yoann\muscle_contribution_box_acceleration\';
OpenSimFolder = 'C:\OpenSim 3.2';
mainDir = cd;
runIK = 1;
selectBestTrial =0; %default = 1
runID = 0;
runSO =1;
runJR = 1;
plotResiduals = 1;
copyFiletoConstraint = 1;



%% run IK
if runIK

for i = 1 : length(trialName)
	
	AnalDir = [importPath '\sujets\\' subject 'd\\new\\' trialName{i}] ;
	cd(AnalDir);
	

	[statusIK{i},cmdoutIK{i}]=system(sprintf(['"%s\\bin\\ik.exe" -S Conf_IK.xml'], OpenSimFolder), '-echo');
 
       fid = fopen([AnalDir '\details_IK_' num2str(i) '.txt'],'w+');
       fprintf(fid,'%s',cmdoutIK{i});
       fclose(fid);
	   
% X = rotation, Y= elevation, Z = retraction ----> sterno-clav
% X = tilt, Y= upward rotation, Z = internal rotation  ----> acromio-clav
% Z = elevation plan, Y= elevation , ZZ = rotation  ----> gleno-hum  
	   
	matrixLim = [   -30   -15   -35;
					 23   -20    20;
					-60   -80   -60];
		
	end
	
	cd(mainDir)
end


for i =1 : length(trialName)
	Q{i}=dlmread([importPath 'sujets\' subject 'd\new\' trialName{i} '\Results_IK.mot'],',',11,0);
	end

	figure
	for i =1 : length(trialName)

	subplot(3,3,i*3-2),plot(Q{i}(:,1),Q{i}(:,8:10))
 	legend('Z = retraction ', 'Y= elevation','X = rotation')
	title('sterno-clav')

	subplot(3,3,i*3-1),plot(Q{i}(:,1),Q{i}(:,11:13))
 	legend('Z = internal rotation ', 'Y= upward rotation','X = tilt')
	title('acromio-clav')

	subplot(3,3,i*3),plot(Q{i}(:,1),Q{i}(:,14:16))
 	legend('GH Z','GH Y','GH ZZ')
	title('GlenoHumeal')
	end




if selectBestTrial

%% import results IK and choose the best trial

	for i =1 : length(trialName)

	fileResultsIK{i} =  [importPath 'sujets\' subject 'd\new\' trialName{i} '\details_IK_' num2str(i) '.txt'];
	[totSquErr_mean(i),RMS_mean(i),maxErr_Max(i),markerNameMaxError(i)]=fct_results_IK(fileResultsIK{i});

	end

% plot IK
	for i =1 : length(trialName)
	Q{i}=dlmread([importPath 'sujets\' subject 'd\new\' trialName{i} '\Results_IK.mot'],',',11,0);
	end

	figure
	for i =1 : length(trialName)

	subplot(3,3,i*3-2),plot(Q{i}(:,8:10))
 	legend('Z = retraction ', 'Y= elevation','X = rotation')
	title('sterno-clav')

	subplot(3,3,i*3-1),plot(Q{i}(:,11:13))
 	legend('Z = internal rotation ', 'Y= upward rotation','X = tilt')
	title('acromio-clav')

	subplot(3,3,i*3),plot(Q{i}(:,14:16))
 	legend('GH Z','GH Y','GH ZZ')
	title('GlenoHumeal')
	end

%% select the best trial
	{'totSquErr_mean','RMS_mean','maxErr_Max'}
	resIK = [totSquErr_mean;RMS_mean;maxErr_Max]'

	bestTrial = input ('choose the best trial (1, 2 or 3)','s');

else
	
	bestTrial = '1';

end

%% run inverse dynamics
if runID
	
	AnalDir = [importPath '\sujets\\' subject 'd\\new\\' trialName{str2num(bestTrial)}] ;
	cd(AnalDir);
	
	[statusID,cmdoutID]=system(sprintf(['"%s\\bin\\id.exe" -S Conf_ID.xml'], OpenSimFolder), '-echo');
	
	cd(mainDir);

end


%% run SO 
if runSO
	AnalDir = [importPath '\sujets\\' subject 'd\\new\\' trialName{str2num(bestTrial)}] ;
	cd(AnalDir);
	
	    [statusSO,cmdoutSO]=system(sprintf('"%s\\bin\\analyze.exe" -S Conf_SO_adjusted.xml', OpenSimFolder), '-echo');
        cd(AnalDir);
        fid = fopen([AnalDir '\ details_SO.txt'],'w+');
        fprintf(fid,'%s',cmdoutSO);
        fclose(fid)
	cd(mainDir)
end



if plotResiduals
	
	AnalDirResid = [importPath '\sujets\' subject 'd\new\' trialName{str2num(bestTrial)} '\results_no_constraint\AdjustedModel_StaticOptimization_force.sto' ] ;
	AnalDirID = [importPath '\sujets\' subject 'd\new\' trialName{str2num(bestTrial)} '\Results_ID.sto' ] ;
	
	resid = dlmread(AnalDirResid,'\t',9,0);
	ID = dlmread(AnalDirID,'\t',7,0);
	
	titles = {'clav','clav','clav',...
	      'scap','scap','scap',...
		  'hum','hum','hum'};
	figure
	for i =1:9
		subplot(3,3,i), plot(ID(:,1),ID(:,i+7)), hold on, plot(resid(:,1),resid(:,i+55),'.')
					title(titles{i}),legend('ID', 'res')
	end
	
	
	
end


if runJR
	AnalDir = [importPath '\sujets\\' subject 'd\\new\\' trialName{str2num(bestTrial)}] ;
	cd(AnalDir);
	
	    [statuJR,cmdoutJR]=system(sprintf('"%s\\bin\\analyze.exe" -S Conf_JR.xml', OpenSimFolder), '-echo');
        cd(AnalDir);
        fid = fopen([AnalDir '\ details_JR.txt'],'w+');
        fprintf(fid,'%s',cmdoutJR);
        fclose(fid)
		cd(mainDir);

	
end



if copyFiletoConstraint
	
	importPath = ['E:\Projet_Yoann\muscle_contribution_box_acceleration\sujets\' subject 'd\new\' trialName{str2num(bestTrial)}];
	exportPath = ['E:\SIM\Test\build32\RelWithDebInfo\subjects\' subject 'd\new\' trialName{str2num(bestTrial)}];
	importPathCopy = ['E:/Projet_Yoann/muscle_contribution_box_acceleration/sujets/' subject 'd/new/' trialName{str2num(bestTrial)}];
	exportPathCopy = ['E:/SIM/Test/build32/RelWithDebInfo/subjects/' subject 'd/new/' trialName{str2num(bestTrial)}];
	mkdir(exportPathCopy);
	
	copyfile([importPathCopy '/Conf_SO_Actuators.xml'],[exportPathCopy '/Conf_SO_Actuators.xml'])
	copyfile([importPathCopy '/Conf_ExternalForce.xml'],[exportPathCopy '/Conf_ExternalForce.xml'])
	copyfile([importPathCopy '/Conf_JR.xml'],[exportPathCopy '/Conf_JR.xml'])
	copyfile([importPathCopy '/Conf_SO_adjusted.xml'],[exportPathCopy '/Conf_SO_adjusted.xml'])
	copyfile([importPathCopy '/Results_IK.mot'],[exportPathCopy '/Results_IK.mot'])

	copyfile(['E:/Projet_Yoann/muscle_contribution_box_acceleration/sujets/' subject 'd/new/' subject 'd_scaled_adjusted_modif.osim'],...
		     [exportPathCopy '/' subject 'd_scaled_adjusted_modif.osim'])
		 
 
	copyfile(['E:/Projet_HuMAnS/Yoann2_HuManS/KinematicModel/SHOULDER/DATA/' subject 'd/0kg/' subject trialName{str2num(bestTrial)} 'f.mot'],...
		     [exportPathCopy '/' subject trialName{str2num(bestTrial)} 'f.mot'])
	
end





