% spiral demo6
% ----------------------
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer 


figure('Units','normalized', 'Position',[.1,.1,.6,.75])


SS = SSpiral(gca);
SS.set('TLim',[0,3*360], 'XLim',[0,240], 'YLim',[0,1], 'XTick',0:20/3:240)  


Y = rand(121,2);
SS.plot(repmat((0:2:240)',[1,2]),Y, 'LineWidth',1, 'Marker', 'o');


pause(1)
% 修改标签格式为最简分数
% Change the label format to the simplest fraction
SS.set('TickLabelFormat',@(x) strtrim(rats(x)))

pause(1)
% 修改标签格式为指定字符串
strCell = [num2cell(char(32*ones(1,25))),{'January','February','March','April','May','June','July','August','September','October','November','December'}];
SS.set('XTickLabel',strCell)
SS.set('TickLabelFont',{'FontSize',14, 'FontName','Times New Roman'})