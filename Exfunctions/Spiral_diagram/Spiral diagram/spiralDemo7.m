% spiral demo7
% ----------------------
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer 


figure('Units','normalized', 'Position',[.1,.1,.6,.75])
SS = SSpiral(gca);
SS.set('TLim',[0,2*360+180], 'XLim',[1,200], 'YLim',[0,1], 'XTick',0:5:200)  

Y = rand(1,100);
SS.scatter(1:2:200,Y,'filled', 'CData',[129,170,174]./255, 'Marker','o');


