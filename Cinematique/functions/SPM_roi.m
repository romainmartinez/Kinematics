function [roi] = SPM_roi(clusters)
xi = clusters;
frames = 100;
taille = length(xi);

roi = false(1, frames);

for iCluster = 1 : taille
    if xi{1, iCluster}.endpoints(1) == 0
        xi{1, iCluster}.endpoints(1) = 1;
    end
    roi(round(xi{1, iCluster}.endpoints(1)) : round(xi{1, iCluster}.endpoints(2))) = true;
end

