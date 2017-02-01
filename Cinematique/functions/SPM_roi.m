function [ output_args ] = SPM_roi(clusters)
 if anova3.spmilist.SPMs{1, idx}.nClusters > 1
        disp(['Warning: nCluster > 1'])
        pause
    end
    roi = false(1, size(Y,2));
    if anova3.spmilist.SPMs{1, idx}.clusters{1, 1}.endpoints(1) == 0
        anova3.spmilist.SPMs{1, idx}.clusters{1, 1}.endpoints(1) = 1;
    end
    roi(anova3.spmilist.SPMs{1, idx}.clusters{1, 1}.endpoints(1):anova3.spmilist.SPMs{1, idx}.clusters{1, 1}.endpoints(2)) = true;



end

