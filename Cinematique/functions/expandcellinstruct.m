function [out_struct] = expandcellinstruct(inp_struct, inp_cell)

inp_struct(1).p        = []; % p of cluster
inp_struct(1).start    = []; % start point of the cluster
inp_struct(1).end      = []; % end point of the cluster
inp_struct(1).diff     = []; % diff between the two comp
inp_struct(1).sup      = []; % factor1 with > diff
inp_struct(1).inf      = []; % factor1 with < diff
inp_struct(1).mean_sup = []; % mean of sup
inp_struct(1).mean_inf = []; % mean of inf
inp_struct(1).max_inf  = []; % mean of inf
inp_struct(1).max_inf  = []; % mean of inf
inp_struct(1).time_sup = []; % time to complete trial of sup
inp_struct(1).time_inf = []; % time to complete trial of inf

idx = 1;

for iRow = 1 : length(inp_struct)
    
    for iCluster = 1 : size(inp_struct(iRow).(inp_cell),1)
        
        out_struct(:,idx) = inp_struct(:,iRow);
        
        out_struct(idx).p     = out_struct(idx).cluster{iCluster,1};
        out_struct(idx).start = out_struct(idx).cluster{iCluster,2};
        out_struct(idx).end   = out_struct(idx).cluster{iCluster,3};
        out_struct(idx).diff     = out_struct(idx).cluster{iCluster,4};
        out_struct(idx).sup      = out_struct(idx).cluster{iCluster,5};
        out_struct(idx).inf      = out_struct(idx).cluster{iCluster,6};
        out_struct(idx).mean_sup = out_struct(idx).cluster{iCluster,7};
        out_struct(idx).mean_inf = out_struct(idx).cluster{iCluster,8};
        out_struct(idx).max_inf  = out_struct(idx).cluster{iCluster,9};
        out_struct(idx).max_inf  = out_struct(idx).cluster{iCluster,10};
        out_struct(idx).time_sup = out_struct(idx).cluster{iCluster,11};
        out_struct(idx).time_inf = out_struct(idx).cluster{iCluster,12};
        idx = idx + 1;
    end
end

out_struct = rmfield(out_struct, inp_cell);

end