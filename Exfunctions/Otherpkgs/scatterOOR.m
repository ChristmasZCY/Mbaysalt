function scatterOOR(ax,varargin)
% Copyright (c) 2023, Zhaoxu Liu / slandarer
% https://mp.weixin.qq.com/s/B9Yv8LCLpb1fOw9Wz1MmMA
if nargin < 1
    ax = gca;
end
if ~isa(ax,'matlab.graphics.axis.Axes')  
    varargin = [{ax}, varargin(:)'];
    ax = gca;
end
ax.NextPlot = 'add';
if isempty(varargin)
    varargin={'filled','CData',[.8,0,0],'LineWidth',1.5,...
    'MarkerEdgeColor',[.8,0,0],'SizeData',120,'Marker','x'};
end

OORHdl = findobj(ax,'Tag','SLANOOR');
if isempty(OORHdl)
    OORHdl = scatter([],[],varargin{:},'Tag','SLANOOR','DisplayName','OOR');
end
fullHdl = findobj(ax,'Type','scatter');
fullXData = [fullHdl(:).XData];
fullYData = [fullHdl(:).YData];

moveAxes();
addlistener(ax,'MarkedClean',@moveAxes);
    function moveAxes(~,~)
        tBool = fullXData >= ax.XLim(2) | fullXData <= ax.XLim(1)...
              | fullYData >= ax.YLim(2) | fullYData <= ax.YLim(1);
        tFullXData = fullXData; 
        tFullYData = fullYData;
        tFullXData(tFullXData >= ax.XLim(2)) = ax.XLim(2);
        tFullXData(tFullXData <= ax.XLim(1)) = ax.XLim(1);
        tFullYData(tFullYData >= ax.YLim(2)) = ax.YLim(2);
        tFullYData(tFullYData <= ax.YLim(1)) = ax.YLim(1);
        tFullXData = tFullXData(tBool);
        tFullYData = tFullYData(tBool);
        OORHdl.XData = tFullXData;
        OORHdl.YData = tFullYData;
    end
end
