function GenerateOpenSimTrcFile(exportPath,trialName,confTrc,markerCoord,subject)

        fid = fopen([exportPath '\' trialName subject '.trc'], 'w+');

        fprintf(fid,'PathFileType\t4\t(X/Y/Z)\t%s\n',[trialName '.trc']);
        fprintf(fid,'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames\n');
        fprintf(fid,'%d\t%d\t%d\t%d',[confTrc.DataRate confTrc.CameraRate confTrc.NumFrames confTrc.NumMarkers]);
        fprintf(fid,'\t%s',confTrc.Units);
        fprintf(fid,'\t%d\t%d\t%d\n',[confTrc.OrigDataRate confTrc.OrigDataStartFrame confTrc.OrigNumFrames]);

        fprintf(fid,'%s\t',confTrc.headers{1});
        fprintf(fid,'%s\t',confTrc.headers{2});

        for i =3:length(confTrc.headers)
         fprintf(fid,'%s\t\t\t',confTrc.headers{i});
        end
         fprintf(fid,'\n');

         fprintf(fid,'\t');

         for i = 1:confTrc.NumMarkers
         fprintf(fid,'\t%s',['X' num2str(i)]);
         fprintf(fid,'\t%s',['Y' num2str(i)]);
         fprintf(fid,'\t%s',['Z' num2str(i)]);
         end

         fprintf(fid,'\n');

        for i =1:size(markerCoord,1) 

           fprintf(fid,'%d\t%d',[confTrc.frame(i) confTrc.time(i)]);
           fprintf(fid,'\t%d',markerCoord(i,:));
           fprintf(fid,'\n');

        end

        fclose(fid);

end


