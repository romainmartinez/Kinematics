

for trial = 1 : length(Alias.Qnames)

%% Variables pour la cr�ation de fichiers OpenSim
    % vecteur temporel (s)
Data(trial).time      = (0:size(Data(trial).Qdata.Q2,2)-1)/Alias.frequency;
    % # frame
Data(trial).frame = [1:length(Data(trial).T)];
    % dimensions
[~,Data(trial).nb_mark,Data(trial).nb_Frame] = size(Data(trial).T);

%% Creation du fichier .trc (le fichier anatomique ou mouvement si on veut faire IK)
    % Headers (fichier)
confTrc.header1 = {'PathFileType' , '4' , '(X/Y/Z)', [Data(trial).trialname '.trc']} ;
    % Headers (Cat�gorie)
confTrc.header2 = {'DataRate' , 'CameraRate' , 'NumFrames' , 'NumMarkers' , 'Units' , 'OrigDataRate' , 'OrigDataStartFrame' , 'OrigNumFrames'} ;
    % Headers (Configuration)
confTrc.header3 = {num2str(Alias.frequency), num2str(Alias.frequency), num2str(Data(trial).nb_Frame),...
                   num2str(Data(trial).nb_mark), 'm' , num2str(Alias.frequency) ,...
                   '1', num2str((Data(trial).nb_Frame))} ;
    % Headers (Marqueurs + temps + frame);
confTrc.header4 = {'Frame#','Time'};
for i=1:Data(trial).nb_mark
    confTrc.header4 = [confTrc.header4 Alias.nameTags(i)];
end
    % Headers (Marqueurs + temps + frame)
confTrc.header5 = {} ;
for i=1:Data(trial).nb_mark
    confTrc.header5 = [confTrc.header5 sprintf('X%d',i) sprintf('Y%d',i) sprintf('Z%d',i)];
end
    % Matrice pour �criture fichier .trc
Data(trial).trcmat    = [round(Data(trial).frame) ; Data(trial).time ; reshape(Data(trial).T,[length(Alias.nameTags)*3 length(Data(trial).T)])]'%(Data(trial).T,[length(Alias.nameTags)*3 length(Data(trial).T)])]';
    % fonction permettant de g�n�rer le .trc
    
   
GenerateOpenSimTrcFileJB(Path.TRCpath, Data(trial).trialname,confTrc,Data(trial).trcmat);
    % Nettoyage Workspace
%clearvars confTrc
end
