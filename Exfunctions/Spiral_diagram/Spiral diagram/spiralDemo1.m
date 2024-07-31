% spiral demo1
% ----------------------
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer 
figure('Units','normalized', 'Position',[.1,.1,.6,.75])

% Create spiral-axes
SS = SSpiral(gca);


pause(1)
% Set theta limit
SS.set('TLim',[0,3*360])  

pause(1)
SS.set('TLim',[120,3*360])

pause(1)
% Set X-axis limit and Y-axis limit
SS.set('XLim',[0,120], 'YLim',[0,10])

pause(1)
SS.set('XTick',0:5:120)

pause(1)
% Set ticks and minor-ticks length
SS.set('TickLength',[.2,.15])

pause(1)
SS.set('XMinorTick','off')



