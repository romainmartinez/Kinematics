function GenerateOpenSimTrcFile(DirModels,confTrc,Tags,time)

    fid   = fopen([DirModels 'Markers.trc'],'w+');
    
    for i = 1:size(confTrc.header1,2)
        fprintf(fid,'%s\t',confTrc.header1{i});
    end
    
    fprintf(fid,'\n');
    
    for i = 1:size(confTrc.header2,2)
        fprintf(fid,'%s\t',confTrc.header2{i});
    end
    fprintf(fid,'\n');

    for i = 1:size(confTrc.header3,2)
        fprintf(fid,'%s\t',confTrc.header3{i});
    end
    fprintf(fid,'\n');
    

    
    for i = 1:size(confTrc.markers,2)
        fprintf(fid,'%s\t',confTrc.markers{i});
    end
    fprintf(fid,'\n');
    
    for i = 1:size(confTrc.header4,2)
        fprintf(fid,'%s\t',confTrc.header4{i});
    end
    
    fprintf(fid,'\n');
    
    fprintf(fid,'\n');
    
    for i =1:size(Tags,3) %nb instants
        fprintf(fid,'%d\t%3.7f\t',i,time(i));
        for j = 1:size(Tags,2) %nb markers
               for k = 1:size(Tags,1) %coordonnee
                   fprintf(fid,'%1.10f',Tags(k,j,i)');
                   fprintf(fid,'\t');
               end
        end
        fprintf(fid,'\n');
    end
    
end


