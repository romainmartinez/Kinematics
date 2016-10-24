close all
clear
clc


%%
conFile=true;
runPK=true;
concatenate=true;

%% settings
subject='TA';
basePathPK=['D:\recherche\yoann\STA_MSK\subject\' ...
                  subject '\opensim\'];
modelName = [subject '_scaled_3dof.osim'];

%% import opensim model for thorax
fidOpensim=fopen([basePathPK modelName]);
modelOpensim=textscan(fidOpensim,'%s');
fclose(fidOpensim);

%% find marker thorax
for i=1:length(modelOpensim{1})
    if length(modelOpensim{1}{i})>=10
        indMarkerTho(i,1)=strcmp(modelOpensim{1}{i}(1:10),'name="mtho');
    end
end

debCoordMarkerTho=find(indMarkerTho==1)+21;
for i=1:length(debCoordMarkerTho)
    coordMarkerTho(:,i)=[str2double(modelOpensim{1}{debCoordMarkerTho(i)}); ...
        str2double(modelOpensim{1}{debCoordMarkerTho(i)+1});
        str2double(modelOpensim{1}{debCoordMarkerTho(i)+2}(1:end-11))
        ];
end



if conFile
    
    %% generate conf PK file
    bodyName = 'thorax';
    relBodyName= 'ground';
    modelPath=[basePathPK modelName];

    timeFile=dlmread([basePathPK 'Res_IK_stat.mot'],'\t',[11 0 15 0]);
    time=[timeFile(1),timeFile(end)];

    for i=1:size(coordMarkerTho,2)
        exportFile{i}=[basePathPK 'Conf_PK\Conf_PK_point_' num2str(i) '.xml'];
        pointName{i}= ['mtho' num2str(i)];
        generatePKconfFile(basePathPK,modelPath,exportFile{i},bodyName,relBodyName,pointName{i},coordMarkerTho(:,i)',time)
    end
    
    % export ST joint
    exportFile=[basePathPK 'Conf_PK\Conf_PK_point_SternoClav.xml'];
    generatePKconfFile(basePathPK,modelPath,exportFile,'clavicle_r',relBodyName,'sternoClav',[0 0 0],time)
    
    % export AC joint
    exportFile=[basePathPK 'Conf_PK\Conf_PK_point_AcromioClav.xml']';
    generatePKconfFile(basePathPK,modelPath,exportFile,'scapula',relBodyName,'acromioClav',[0 0 0],time)
    
    % GH joint
    exportFile=[basePathPK 'Conf_PK\Conf_PK_point_GH.xml']';
    generatePKconfFile(basePathPK,modelPath,exportFile,'humerus',relBodyName,'GH',[0 0 0],time)
    
end



%% run PK
if runPK
    
    mainDir = cd;
    OpenSimFolder = 'C:\OpenSim 3.3';
    
    AnalDir = [basePathPK 'Conf_PK'];
    cd(AnalDir);
    
    for i =1: size(coordMarkerTho,2)
        i
        [statusPK,cmdoutPK]=system(sprintf(['"%s\\bin\\analyze.exe" -S Conf_PK_point_' num2str(i) '.xml'], OpenSimFolder));
        
    end
    
    [statusPK,cmdoutPK]=system(sprintf(['"%s\\bin\\analyze.exe" -S Conf_PK_point_SternoClav.xml'], OpenSimFolder));
    
    [statusPK,cmdoutPK]=system(sprintf(['"%s\\bin\\analyze.exe" -S Conf_PK_point_AcromioClav.xml'], OpenSimFolder));
    
    [statusPK,cmdoutPK]=system(sprintf(['"%s\\bin\\analyze.exe" -S Conf_PK_point_GH.xml'], OpenSimFolder),'-echo');
    
    cd(mainDir);
    
    %% delete extra files (pos,vel, acc)
    
    velFiles=dir(fullfile([basePathPK 'results_PK\'], '*vel.sto'));
    accFiles=dir(fullfile([basePathPK 'results_PK\'], '*acc.sto'));
    
    for j=1:length(velFiles)
        delete([basePathPK 'results_PK\' velFiles(j).name]);
        delete([basePathPK 'results_PK\' accFiles(j).name]);
    end
    
end

%% concatenate all results

if concatenate
    
    posFiles=dir(fullfile([basePathPK '\results_PK'], '*mtho*pos.sto'));
    for i=1:length(posFiles)
        pos{i}=dlmread([basePathPK '\results_PK\' posFiles(i).name],'\t',8,1);
    end
    posConcat=pos{1};
    
    for i=2:length(posFiles)
        posConcat=[posConcat,pos{i}];
    end
    
    % sternoClav
    sterno = dir(fullfile([basePathPK 'results_PK'], '*sternoClav_pos.sto'));
    posSterno=dlmread([basePathPK 'results_PK\' sterno.name],'\t',8,1);
    
    % acromioClav
    acromio = dir(fullfile([basePathPK '\results_PK'], '*acromioClav_pos.sto'));
    posAcromio=dlmread([basePathPK '\results_PK\' acromio.name],'\t',8,1);
    
    % GH
    GH = dir(fullfile([basePathPK '\results_PK'], '*GH_pos.sto'));
    posGH=dlmread([basePathPK '\results_PK\' GH.name],'\t',8,1);
    
    
    %% export
    dlmwrite([basePathPK '\results_PK\markerThoCoord.txt'],posConcat)
    dlmwrite([basePathPK '\results_PK\markerSternoCoord.txt'],posSterno)
    dlmwrite([basePathPK '\results_PK\markerAcromioCoord.txt'],posAcromio)
    dlmwrite([basePathPK '\results_PK\markerGHCoord.txt'],posGH)
    
end