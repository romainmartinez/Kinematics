function [segmentMarkers, segmentDoF] = segment_RBDL
%% identification des marqueurs correspondant à chaque segement

% handelbow
segmentMarkers.handelbow = 32:43;
% GH
segmentMarkers.GH        = 25:31;
% SCAC
segmentMarkers.SCAC      = 11:24;
% RoB
segmentMarkers.RoB       = 1:10;

%% identification des DoF correspondant à chaque segement

% handelbow
segmentDoF.handelbow     = 25:28;
% GH
segmentDoF.GH            = 19:24;
% SCAC
segmentDoF.SCAC          = 13:18;
% RoB
segmentDoF.RoB           = 1:12;

