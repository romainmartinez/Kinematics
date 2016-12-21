function [SPM] = selectSPMvariable(SPM,i)
switch i
    case 1
        SPM.comp = SPM.delta_hand;
    case 2
        SPM.comp = SPM.delta_GH;
    case 3
        SPM.comp = SPM.delta_SCAC;
    case 4
        SPM.comp = SPM.delta_RoB;
end



