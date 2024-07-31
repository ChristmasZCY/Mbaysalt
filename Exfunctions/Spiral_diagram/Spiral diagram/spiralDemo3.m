% spiral demo3
% ----------------------
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer 

figure('Units','normalized', 'Position',[.1,.1,.6,.75])
% Create spiral-axes
SS2 = SSpiral(gca);
SS2.set('TLim',[0,2*360+180], 'XLim',[0,200]+.5, 'YLim',[0,1], 'XTick',0:5:200)  

% Set background color to light-blue
SS2.set('BackgroundColor',[228,243,245]./255)

X = rand(1,200);
SS2.bar(X, 'FaceColor',[253,193,202]./255, 'EdgeColor','w');

% Set tick-labels font
SS2.set('TickLabelFont', {'FontSize',10, 'FontName','Times New Roman', 'Color',[0,0,.5]})