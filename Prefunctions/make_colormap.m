function varargout = make_colormap(varargin)
%MAKE_COLORMAP Create a colormap from a list of colors
rr(1:10,1) = 0;                     % 0 0 1
gg(1:10,1) = linspace(0,0.9,10);    %  到
bb(1:10,1) = 1;                     % 0 1 1

rr(11:20,1) = linspace(0,0.9,10);    % 0 1 1
gg(11:20,1) = 1;                     %  到
bb(11:20,1) = linspace(1,0.1,10);    % 1 1 0

rr(21:30,1) = 1;                     % 1 1 0
gg(21:30,1) = linspace(1,0.1,10);    %  到
bb(21:30,1) = 0;                     % 1 0 0

cc=[rr gg bb];
clear rr bb gg;

varargout{1}=cc;
end