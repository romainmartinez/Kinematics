function [out_struct] = expandcellinstruct(inp_struct, inp_cell, inp_cond, inp_col)

idx = 1;
for iRow = 1 : length(inp_struct)
    inp_struct(iRow).p = [];
    inp_struct(iRow).start = [];
    inp_struct(iRow).end = [];
    
    if inp_struct(iRow).(inp_col) == inp_cond
        for iCluster = 1 : size(inp_struct(iRow).(inp_cell),1)
            
            out_struct(:,idx) = inp_struct(:,iRow);
            
            out_struct(idx).p     = out_struct(idx).cluster{iCluster,1};
            out_struct(idx).start = out_struct(idx).cluster{iCluster,2};
            out_struct(idx).end   = out_struct(idx).cluster{iCluster,3};
            
            idx = idx + 1;
        end
    else
        out_struct(:,idx) = inp_struct(:,iRow);
        idx = idx+1;
    end
end

end