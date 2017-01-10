function [out_struct] = expandcellinstruct(inp_struct, inp_cell, inp_cond, inp_col)

for iRow = 1 : length(inp_struct)
    if inp_struct(iRow).(inp_col) == inp_cond
        for iCluster = 1 : size(inp_struct(iRow).(inp_cell),1)
%             inp_struct(:,iRow) = 
            xi(iRow).p     = xi(iRow).cluster{iCluster,1};
            xi(iRow).start = xi(iRow).cluster{iCluster,2};
            xi(iRow).end   = xi(iRow).cluster{iCluster,3};
        end
    end
end

end