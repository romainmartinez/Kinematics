function [SPM, string] = selectSPMvariable(SPM,i)
switch i
    case 1
        SPM.comp = SPM.delta_hand;
        string   = 'delta_hand';
    case 2
        SPM.comp = SPM.delta_GH;
        string   = 'delta_delta_GH';
    case 3
        SPM.comp = SPM.delta_SCAC;
        string   = 'delta_delta_SCAC';
    case 4
        SPM.comp = SPM.delta_RoB;
        string   = 'delta_delta_RoB';
end



