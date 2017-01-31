function [out_struct] = expandcellinstruct(inp_struct, inp_cell)


inp_struct(1).p     = [];
inp_struct(1).start = [];
inp_struct(1).end   = [];
inp_struct(1).diff  = [];
inp_struct(1).sens  = [];

idx = 1;

for iRow = 1 : length(inp_struct)
    
    for iCluster = 1 : size(inp_struct(iRow).(inp_cell),1)
        
        out_struct(:,idx) = inp_struct(:,iRow);
        
        out_struct(idx).p     = out_struct(idx).cluster{iCluster,1};
        out_struct(idx).start = out_struct(idx).cluster{iCluster,2};
        out_struct(idx).end   = out_struct(idx).cluster{iCluster,3};
        
        if size(inp_struct(1).cluster,2) == 5
            out_struct(idx).diff     = out_struct(idx).cluster{iCluster,4};
            out_struct(idx).sens     = out_struct(idx).cluster{iCluster,5};
        end
        idx = idx + 1;
    end
end

out_struct = rmfield(out_struct, inp_cell);

end