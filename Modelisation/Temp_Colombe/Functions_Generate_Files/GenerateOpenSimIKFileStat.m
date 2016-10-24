function GenerateOpenSimIKFileStat(importPath,exportPath,Subject)

        fid = fopen([importPath '\Conf_IK_static.xml']);
        fid2 = fopen([exportPath '\Conf_IK_static.xml'], 'w+');

        count=0;
        tline = fgetl(fid);
        while ischar(tline)
            count = count+1;
            if (count==1) % first line
                fprintf(fid2,'%s\n',tline);  

            elseif (count==9)
                fprintf(fid2,'<model_file>%s_scaled_adjusted.osim</model_file>\n',Subject);

            else
            fprintf(fid2,'%s',tline);
            end
            tline = fgets(fid);
        end

        fclose(fid);
        fclose(fid2);

end
	
	

