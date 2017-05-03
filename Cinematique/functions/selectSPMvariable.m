function [SPM, string] = selectSPMvariable(SPM,delta)
switch delta
    case 1
        SPM.comp = SPM.deltahand;
    case 2
        SPM.comp = SPM.deltaGH;
    case 3
        SPM.comp = SPM.deltaSCAC;
    case 4
        SPM.comp = SPM.deltaRoB;
    otherwise
        disp('Wrong delta')
end




