close all
clear
clc

%% import setting file
settingFile = fct_importByLine('D:\recherche\yoann\STA_MSK\subject\TA\results_IK\modelParam.txt');

%% read setting file
[pathStaticFile,subject,nbSeg,segNamMod,...
    markNamModTotal, nbMarkerSeg,...
    markerBySeg,fileType,ellipsoidType,...
    thoFile,scapNb,scapPos,startScapVec,...
    CoRType,nbCoR,CoRFile,segAxis] = readModelConf(settingFile);


%% import static
if strcmp(fileType,'opensim')
    dataStaticFile=dlmread(pathStaticFile,'\t',5,1);
    dataStatic=dataStaticFile(:,2:end);
    
    %% import headers
    fid=fopen(pathStaticFile);
    headTmp=textscan(fid,'%s');
    begHead=find(strcmp(headTmp{1},'Time')==1,1)+1;
    finHead=find(strcmp(headTmp{1},'X1')==1,1)-1;
    headers=headTmp{1}(begHead:finHead);
    
else
    
    disp('file type problem !!!!')
    
end

%% header correspondance total markers
for i=1:length(markNamModTotal)
    indCorrMarker(i,1) = find(strcmp(headers,markNamModTotal{i})==1);
end

%% header correspondance per segment
for j=1:nbSeg
    for i=1:length(markerBySeg{j})
        indMarkers{j}(i,1) = find(strcmp(headers,markerBySeg{j}(i))==1);
    end
end


%% matrix length correction
if length(headers)*3 < size(dataStatic,2)
    indDiff = length(headers)*3-size(dataStatic,2);
    dataStatic(:,end+indDiff+1)=[];
    
elseif length(headers)*3 > size(dataStatic,2)
    
    disp('problem in matrix length')
    
end


%% take the mean of the position
staticPos= nanmean(dataStatic(1:10,:));

%% reorg data in column
mAnatoTmp=fct_matrixGlob2column(staticPos);

%% reorg for opensim if needed
if strcmp(fileType,'opensim')
    mAnato=[-mAnatoTmp(3,:); ...
        -mAnatoTmp(1,:);  ...
        mAnatoTmp(2,:)];
    
else
    mAnato =mAnatoTmp;
end

%% attribute coordinates 2 marker name

for i=1:length(markNamModTotal)
    tmp=genvarname(markNamModTotal{i});
    eval([tmp '= mAnato(:,indCorrMarker(i));']);
end

%% ellipoid
if strcmp(ellipsoidType,'opensim')
    
    % import marker thorax coordinates
    dataTho=dlmread(thoFile,',');
    dataThoMean=nanmean(dataTho(1:2,:));
    dataThoReorg=fct_matrixGlob2column(dataThoMean);
    
    % reog in opensim coordinate system
    coordMarkerTho=[-dataThoReorg(3,:); ...
        -dataThoReorg(1,:);  ...
        dataThoReorg(2,:)];
    
    centerGuess=[sum(coordMarkerTho,2)/size(coordMarkerTho,2)]';
    
    % optimisation options
    ellipsoidParametersGuess=[centerGuess 0.1 0.1 0.1];
    LB=[centerGuess-1 , 0 , 0 , 0];
    UB=[centerGuess+1 , 1, 1, 1];
    options=optimset('display','none','TolX', 1e-10, 'TolFun', 1e-10);%,'MaxFunEvals',100000,'MaxIter',1000);
    
    [ellipsoidParameters errorEll]=lsqnonlin(@fct_ellipsoidFit,ellipsoidParametersGuess,LB,UB,options,coordMarkerTho);
    
    [xEll,yEll,zEll] = ellipsoid(ellipsoidParameters(1),ellipsoidParameters(2),ellipsoidParameters(3),...
        ellipsoidParameters(4),ellipsoidParameters(5),ellipsoidParameters(6),50);
    
    figure
    plot3(coordMarkerTho(1,:),coordMarkerTho(2,:),coordMarkerTho(3,:),'o')
    hold on
    surf(xEll,yEll,zEll,'FaceColor','y','FaceAlpha',.1,'EdgeAlpha',.2)
    axis equal
    
    %% tranform in mm
    xEll=xEll*1000;
    yEll=yEll*1000;
    zEll=zEll*1000;
    ellipsoidParameters=ellipsoidParameters*1000;
    
else
    disp('problem in ellipsoid definition')
    
end

%% new marker on the scapula

if scapNb > 0
    
    for i=1:length(scapPos) % number of contact points
        scapulaMarkerNewGlob(:,i) = eval(scapPos{i});
    end
end

%% CoR
if strcmp(CoRType,'opensim')
    for i=1:str2num(nbCoR)
        
        % import sternoClavicular joint coordinates
        dataCoR{i}=dlmread(CoRFile{i},',');
        dataCoRMean{i}=mean(dataCoR{i}(1:2,:))*1000;
        
        dataCoRReorg{i}=fct_matrixGlob2column(dataCoRMean{i});
        
        % reog in opensim coordinate system
        coordCoR(:,i)=[-dataCoRReorg{i}(3,:); ...
            -dataCoRReorg{i}(1,:);  ...
            dataCoRReorg{i}(2,:)];
        CoRName = ['CoR' num2str(i)];
        eval([CoRName '= coordCoR(:,i);']);
    end
    
end

%% origins in global
originGlobal = [zeros(3,1),... % ground-thorax
    coordCoR ];  % radius-hand


%% define axis
for i=1:nbSeg % number of segment
    for j=1:3 % nb axis per segment
        indAxis{i}{j}=strfind(segAxis{i}{j},'axe');
        %     indCoR{i}{j}=strfind(segAxis{i}{j},'CoR');
        if ~isempty (indAxis{i}{j})
            axisRef{i}(1:3,str2double(segAxis{i}{j}(1)))=cross(axisRef{str2double(segAxis{i}{j}(12))}(:,str2double(segAxis{i}{j}(14))),axisRef{str2double(segAxis{i}{j}(19))}(:,str2double(segAxis{i}{j}(21))));
            
            %     elseif ~isempty (indCoR{i}{j})
            
        else
            axisRef{i}(1:3,str2double(segAxis{i}{j}(1)))=eval(segAxis{i}{j}(3:end));
            
        end
    end
end


%% normalize axis
for n=1:nbSeg
    for i =1:size(axisRef{n},2)
        axisNorm{n}(1:3,i)= axisRef{n}(1:3,i)./norm(axisRef{n}(1:3,i));
    end
end

%% class markers by segments


for n =1:nbSeg
    mAnatoSeg{n}=mAnato(:,indMarkers{n});
    mAnatoDisp{n}=[mAnato(:,indMarkers{n}) originGlobal(:,n)];
    %  mAnatoDisp{n}=[mAnato(:,indMarkers{n})];
end

%% add new scapula points
if scapNb > 0
    
    % find indice segment for the scapula
    
    indScapula = find(strcmp(segNamMod,'scapula'));
    
    if isempty(indScapula)
        disp('no SCAPULA for segment names')
        
    else
        for i=1:length(scapPos) % number of contact points
            mAnatoDisp{indScapula}(:,size(mAnatoDisp{indScapula},2)+1)=scapulaMarkerNewGlob(:,i);
            mAnatoSeg{indScapula}(:,size(mAnatoSeg{indScapula},2)+1)=scapulaMarkerNewGlob(:,i);
        end
    end
else
    indScapula=[];
end

%% delete ground origin for thorax display
mAnatoDisp{1}(:,end)=[];

%% distance scapula ellipsoid
if scapNb > 0
    % transform ellipsoid coordinates
    ellipsoidX=xEll(1,1:end);
    for i=2:length(xEll)
        ellipsoidX=[ellipsoidX xEll(i,1:end)];
    end
    ellipsoidY=yEll(1,1:end);
    for i=2:length(yEll)
        ellipsoidY=[ellipsoidY yEll(i,1:end)];
    end
    ellipsoidZ=zEll(1,1:end);
    for i=2:length(zEll)
        ellipsoidZ=[ellipsoidZ zEll(i,1:end)];
    end
    
    ellipsoidCoord=[ellipsoidX;ellipsoidY;ellipsoidZ];
    
    
    % find the closest point on the ellipsoid
    
    for i=1:length(scapPos) % number of contact points
        
        
        vectorEllScap{i}=repmat(mAnatoDisp{indScapula}(:,end-i+1),1,size(ellipsoidCoord,2))-ellipsoidCoord;
        distEllScap{i}=sqrt(vectorEllScap{i}(1,:).^2+vectorEllScap{i}(2,:).^2+vectorEllScap{i}(3,:).^2);
        indScapElliTmp(i)=find(min(distEllScap{i})==distEllScap{i},1);
        
    end
    indScapElli=fliplr(indScapElliTmp); % replace in a ggod order because of the previous loop

else
    xEll=[];
yEll=[];
zEll=[];
ellipsoidCoord=[];
distEllScap=[];
end

%% new point in the scapula local reference system

% RT matrix anato seg 1:n
for n=1:nbSeg
    RTanato{n} = fct_matrixRT(axisNorm{n}, originGlobal(:,n));
end

% global to local
mAnatoLoc=cell(1,nbSeg);

for n=1:nbSeg
    RTglob2loc{n} = fct_matrixGlob2Loc(RTanato{n});
    if ~isempty(mAnatoSeg{n})
        
        mAnatoLoc{n} = RTglob2loc{n}*[mAnatoSeg{n};ones(1,size(mAnatoSeg{n},2))];
        originLoc{n} = RTglob2loc{n}*[originGlobal(:,n);ones(1,size(originGlobal(:,n),2))];
    end
    
end

% ellipsoid in the throax reference system
if strcmp(ellipsoidType,'opensim') || strcmp(ellipsoidType,'kinematics')
    
    indThorax = find(strcmp(segNamMod,'thorax'));
    
    if isempty(indThorax)
        disp('no THORAX for segment names')
        
    else
        mAnatoLoc{length(mAnatoLoc)+1}=RTglob2loc{indThorax}*[ellipsoidCoord;ones(1,size(ellipsoidCoord,2))];
    end
    
end

% global to local n-1
originLoc_N_1{1}=[0;0;0;1]; % origin thorax in ground
for n=2:nbSeg
    originLoc_N_1{n} = RTglob2loc{n-1}*[originGlobal(:,n);ones(1,size(originGlobal(:,n),2))];
end


%% vector sacpula point in scap ref system relative to mid cluster
if scapNb > 0
    indStartVec = find(strcmp(markerBySeg{indScapula},startScapVec));
    vecMidClusterScapulaPoint=mAnatoLoc{indScapula}(1:3,end-length(scapPos)+1:end)-repmat(mAnatoLoc{indScapula}(1:3,indStartVec),1,length(scapPos));
else
    vecMidClusterScapulaPoint=[];
end

%% settings figure
ratioAxis = 0.015;

colorAxis=[1 0 0;
    0 1 0;
    0 0 1];

colorMarker = [0 0 0;
    1 0 0;
    0 1 0;
    0 0 1;
    1 0 1;
    1 1 0;
    0 0 1];

%% plot static positon
figure
% markers
plot3(-staticPos(:,3:3:end),-staticPos(:,1:3:end),staticPos(:,2:3:end),'o')
hold on
if scapNb > 0
    plot3(scapulaMarkerNewGlob(1,:),scapulaMarkerNewGlob(2,:),scapulaMarkerNewGlob(3,:),'m>')
end
% axis
for n=1:nbSeg
    for i =1:size(axisNorm{n} ,2)
        %         hold on
        plot3([originGlobal(1,n) originGlobal(1,n)+axisNorm{n}(1,i)/ratioAxis],...
            [originGlobal(2,n) originGlobal(2,n)+axisNorm{n}(2,i)/ratioAxis],...
            [originGlobal(3,n) originGlobal(3,n)+axisNorm{n}(3,i)/ratioAxis],...
            'color',colorAxis(i,:),'linewidth',3);
    end
end

% lines
for n=1:nbSeg % nb segment
    for i=1:size(mAnatoDisp{n},2) % nb markers per segment
        for j=i:size(mAnatoDisp{n},2) % nb markers per segment
            plot3([mAnatoDisp{n}(1,i),mAnatoDisp{n}(1,j)],...
                [mAnatoDisp{n}(2,i),mAnatoDisp{n}(2,j)],...
                [mAnatoDisp{n}(3,i),mAnatoDisp{n}(3,j)],...
                'color',colorMarker(n,:))
            
        end
    end
    
end

if scapNb > 0
    % ellipsoid
    surf(xEll,yEll,zEll,'FaceColor','y','FaceAlpha',.1,'EdgeAlpha',.2)
    
    if length(indScapElli)==1
        % line between the scapula and ellipsoid
        plot3(ellipsoidCoord(1,indScapElli(1)), ellipsoidCoord(2,indScapElli(1)),ellipsoidCoord(3,indScapElli(1)),'>m')
        
        plot3([ellipsoidCoord(1,indScapElli(1)) mAnatoDisp{indScapula}(1,end)],...
            [ellipsoidCoord(2,indScapElli(1)) mAnatoDisp{indScapula}(2,end)],...
            [ellipsoidCoord(3,indScapElli(1)) mAnatoDisp{indScapula}(3,end)],'m')
        
    elseif length(indScapElli)==2
        plot3(ellipsoidCoord(1,indScapElli(1)), ellipsoidCoord(2,indScapElli(1)),ellipsoidCoord(3,indScapElli(1)),'>m')
        
        plot3([ellipsoidCoord(1,indScapElli(1)) mAnatoDisp{indScapula}(1,end-1)],...
            [ellipsoidCoord(2,indScapElli(1)) mAnatoDisp{indScapula}(2,end-1)],...
            [ellipsoidCoord(3,indScapElli(1)) mAnatoDisp{indScapula}(3,end-1)],'m')
        
        
        plot3([ellipsoidCoord(1,indScapElli(2)) mAnatoDisp{indScapula}(1,end)],...
            [ellipsoidCoord(2,indScapElli(2)) mAnatoDisp{indScapula}(2,end)],...
            [ellipsoidCoord(3,indScapElli(2)) mAnatoDisp{indScapula}(3,end)],'m')
        plot3(ellipsoidCoord(1,indScapElli(2)), ellipsoidCoord(2,indScapElli(2)),ellipsoidCoord(3,indScapElli(2)),'>m')
    end
    
end
axis equal

%% create structure 2 export
% for i=1:length(indHeaders)
%     mod.header{i,1}=  headers{indHeaders(i)};
% end
mod.subject=subject;
mod.nbSeg=nbSeg;
mod.segName = segNamMod;
mod.markNamModTotal=markNamModTotal;
mod.markerBySeg=markerBySeg;
mod.nbMarkerSeg=nbMarkerSeg;
mod.scapNb=scapNb;
mod.startScapVec=startScapVec;
mod.axisNorm=axisNorm;
mod.originGlobal=originGlobal(:,1:nbSeg);
mod.mAnatoDisp=mAnatoDisp;
mod.mAnatoSeg=mAnatoSeg;
mod.ellipsoid.x=xEll;
mod.ellipsoid.y=yEll;
mod.ellipsoid.z=zEll;
mod.indScapula=indScapula;
mod.ellipsoid.coord=ellipsoidCoord;
mod.RTanato=RTanato;
for i=1:length(distEllScap)
    mod.minDistanceElliScapStat(i)=min(distEllScap{i});
end
mod.vectorNewMarkerScap=vecMidClusterScapulaPoint;
mod.mAnatoLoc=mAnatoLoc;
mod.originLoc=originLoc;
mod.originLoc_N_1=originLoc_N_1;

%% export model informations
% mkdir('\\134.214.26.46\d$\recherche\yoann\STA_MSK\subject\TA\results_IK');
% save(['\\134.214.26.46\d$\recherche\yoann\STA_MSK\subject\TA\results_IK\modelRegInfo.mat'],'mod');

