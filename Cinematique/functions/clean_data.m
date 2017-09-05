function [idx, data] = clean_data(data, varargin)
% Clean_data allows to select data from the plot and replace it (by NaN, 0 or []) and return
% index of the selected data
%
% Input data should be nframe * observations
% Outputs :
%     'idx'  = index of the selected data
%     'data' = data with nan on the selected trials

% figure
S.fh = figure('units','normalized',...
    'outerposition',[0.1 0.1 0.8 0.8],...
    'menubar','none',...
    'numbertitle','off',...
    'name','GUI_18',...
    'resize','off');
% axes
S.ax = axes('units','normalized',...
    'position',[0.05 0.1 0.8 0.8],...
    'fontsize',8,...
    'nextplot','replacechildren');
% update button
S.but = uicontrol('style','push',...
    'units','normalized',...
    'position',[0.87 0.5 0.1 0.05],...
    'fontsize',14,...
    'string','update',...
    'Callback',{@but_funct,S});

% close button
S.clo = uicontrol('style','push',...
    'units','normalized',...
    'position',[0.87 0.4 0.1 0.05],...
    'fontsize',14,...
    'string','close', ...
    'Callback',@(h,e)closeFig(h,e,S));

idx = [];

while ishandle(S.fh)
    uiwait(S.fh);
end
    function but_funct(varargin)
        plot(data)
        
        [pind] = selectdata('selectionmode','Brush');
        
        pind = pind(end:-1:1);
        
        idx = vertcat(idx, find(~cellfun('isempty', pind)));
        data(:,~cellfun('isempty', pind)) = NaN;
    end

    function closeFig(varargin)
        S = varargin{3};
        delete(S.fh)
    end
end