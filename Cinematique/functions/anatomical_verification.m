%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%_____________________________________________________________________________

clear all; close all; clc

% path
importpath = '\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\contribution_articulation\figures\anatomical_corrected\';

fig_names  = dir([importpath '*.fig']);


%% Interface graphique de suppresion des essais
set(figure,'units','normalized','outerposition',[0 0 1 1]);
index = 0;
txt = uicontrol('Units','normalized','Position',[0.15 0.9 0.15 0.05],'String','Sujet','Style','text','FontSize', 16);
next = uicontrol('Units','normalized','Position',[0.90 0.5 0.05 0.05],'String','Next','Callback',{@myCB, 1, index, importpath, fig_names, gcf, txt});
previous = uicontrol('Units','normalized','Position',[0.84 0.5 0.05 0.05],'String','Previous','Callback',{@myCB, 2, index, importpath, fig_names, gcf, txt});

guidata(txt,index);


function index = myCB(ObjH, EventData, CB, index, path, fig_names, axe, txt)
    switch CB
        case 1
            cla reset
            set(gca,'visible','off')
            index = guidata(txt);
            index = index + 1;
            g = openfig([path fig_names(index).name],'invisible');
            copyobj(get(g, 'CurrentAxes'), axe);
            delete(g);
            rotate3d on
            set(txt,'String',fig_names(index).name);
            guidata(txt,index);
        case 2
            cla reset
            set(gca,'visible','off')
            index = guidata(txt);
            index = index - 1;
            g = openfig([path fig_names(index).name],'invisible');
            copyobj(get(g, 'CurrentAxes'), axe);
            delete(g);
            rotate3d on
            set(txt,'String',fig_names(index).name);
            guidata(txt,index);
    end
end