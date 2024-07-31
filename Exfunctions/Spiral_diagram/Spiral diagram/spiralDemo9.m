% spiral demo9
% ----------------------
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer 

rng(3)

% draw dendrogram
Data = rand(200,3);
N = 5;
Z = linkage(Data,'average');
T = cluster(Z,'maxclust',N);
cutoff = median([Z(end-(N-1),3), Z(end-(N-2),3)]);
[LineSet, ~, order] = dendrogram(Z, 0, 'Orientation', 'top');
XSet = reshape([LineSet(:).XData], 4, []);
YSet = reshape([LineSet(:).YData], 4, []);
YSet = max(max(YSet))-YSet;
close all


figure('Units','normalized', 'Position',[.1,.1,.6,.75])
SS = SSpiral(gca);
SS.set('TLim',[0,2*360+180], 'XLim',[0,200]+.5, 'YLim',[0,max(max(YSet))], 'XTick',0:5:200) 
% use function obj.line to draw lines with different length
SS.line(XSet, YSet, 'Color','k', 'LineWidth',1);


CList = [ 0.3569    0.0784    0.0784
    0.6784    0.4471    0.1725
    0.1020    0.3882    0.5176
    0.1725    0.4196    0.4392
    0.2824    0.2275    0.2902
         0         0         0];
TT = T(order);
classNum = unique(TT, 'stable');
for i = 1:N
    tX = [find(TT==classNum(i),1,'first')-.5, find(TT==classNum(i),1,'last')+.5];
    lgdHdl(i) = SS.xregion(tX, 'FaceColor',CList(i,:), 'FaceAlpha',.4);
end

legend(lgdHdl, {'Set-S','Set-L','Set-A','Set-N','Set-M'})

