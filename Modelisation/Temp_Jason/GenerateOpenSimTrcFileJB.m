function GenerateOpenSimTrcFileJB(exportPath,trialname,confTrc,trcmat)
%% Ouverture
    fid   = fopen([exportPath trialname '.trc'],'w+');
%% Écriture des headers
    fprintf(fid,'%s\t',confTrc.header1{:});
    fprintf(fid,'\r\n');
    fprintf(fid,'%s\t',confTrc.header2{:});
    fprintf(fid,'\r\n');
    fprintf(fid,'%s\t',confTrc.header3{:});
    fprintf(fid,'\r\n');
    fprintf(fid,'%s\t',confTrc.header4{1:2});
    fprintf(fid,'%s\t\t\t',confTrc.header4{3:end});
    fprintf(fid,'\r\n\t\t');
    fprintf(fid,'%s\t',confTrc.header5{:});
    fprintf(fid,'\r\n\r\n');
%% Écriture des datas
    fprintf(fid, ['%u\t' repmat('%f\t', 1, size(trcmat, 2)-1) '\r\n'], trcmat');
%% Fermeture   
    fclose(fid);
end