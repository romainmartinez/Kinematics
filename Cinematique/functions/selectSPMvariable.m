function [SPM, string, idx] = selectSPMvariable(SPM,delta)

switch delta
    case 1
        SPM.comp = SPM.delta_hand;
        string   = 'delta_hand';
    case 2
        SPM.comp = SPM.delta_GH;
        string   = 'delta_GH';
    case 3
        SPM.comp = SPM.delta_SCAC;
        string   = 'delta_SCAC';
    case 4
        SPM.comp = SPM.delta_RoB;
        string   = 'delta_RoB';
    otherwise
        disp('Wrong delta')
end




