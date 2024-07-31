% spiral demo4
% ----------------------
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer 

figure('Units','normalized', 'Position',[.1,.1,.6,.75])

% Create spiral-axes
SS1 = SSpiral(gca);
SS1.set('TLim',[0,2*360+180], 'XLim',[0,200]+.5, 'YLim',[0,2], 'XTick',0:5:200)  

X = rand(200,2);
SS1.bar(X, 'FaceColor',[0.46,0.67,0.18; 0.30,0.74,0.93]);
legend({'AAA','BBB'}, 'FontSize',12, 'FontName','Times New Roman')




% =========================================================================
figure('Units','normalized', 'Position',[.1,.1,.6,.75])

% Create spiral-axes
SS2 = SSpiral(gca);
SS2.set('TLim',[0,2*360+180], 'XLim',[0,200]+.5, 'YLim',[-1,1], 'XTick',0:5:200)  

X = rand(200,2)-.5;
SS2.bar(X, 'FaceColor',[0.46,0.67,0.18; 0.30,0.74,0.93]);
legend({'AAA','BBB'}, 'FontSize',12, 'FontName','Times New Roman')