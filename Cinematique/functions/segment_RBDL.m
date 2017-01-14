function [segmentMarkers, segmentDoF] = segment_RBDL(model)
%% identification des marqueurs et DoF correspondant à chaque segement
switch model
    case 2
        % handelbow
        segmentMarkers.handelbow = 32:43;
        % GH
        segmentMarkers.GH        = 25:31;
        % SCAC
        segmentMarkers.SCAC      = 11:24;
        % RoB
        segmentMarkers.RoB       = 1:10;
        
        
        % handelbow
        segmentDoF.handelbow     = 25:28;
        % GH
        segmentDoF.GH            = 19:24;
        % SCAC
        segmentDoF.SCAC          = 13:18;
        % RoB
        segmentDoF.RoB           = 1:12;
    case 3
        % handelbow
        segmentMarkers.handelbow = 32:43;
        % GH
        segmentMarkers.GH        = 25:31;
        % SCAC
        segmentMarkers.SCAC      = 11:24;
        % RoB
        segmentMarkers.RoB       = 1:10;
        
        
        % handelbow
        segmentDoF.handelbow     = 28:31;
        % GH
        segmentDoF.GH            = 22:27;
        % SCAC
        segmentDoF.SCAC          = 13:21;
        % RoB
        segmentDoF.RoB           = 1:12;
        
    otherwise
        disp('Choisir un modèle valide')
end

