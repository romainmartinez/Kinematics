function GenerateOpenSimMotFile(DirModels,confMot,Kin)

    fid   = fopen([DirModels 'Essai.mot'],'w+');
    
    for i = 1:size(confMot.header)
        fprintf(fid,'%s\t',confMot.header{i});
        fprintf(fid,'\n');
    end
    
    fprintf(fid,'\n');
    
    fprintf(fid,'%s\t',confMot.endheader{1});
    fprintf(fid,'\n');
        
    fprintf(fid,'\n');

    for i = 1:size(confMot.nameddl,2)
        fprintf(fid,'%s\t',confMot.nameddl{i});
    end
    
    fprintf(fid,'\n');
    
    for i =1:size(Kin,2) %nb instants
        for j = 1:size(Kin,1) %nb markers
            fprintf(fid,'%1.10f',Kin(j,i));
            fprintf(fid,'\t','');
        end
        fprintf(fid,'\n');
    end
    
end


