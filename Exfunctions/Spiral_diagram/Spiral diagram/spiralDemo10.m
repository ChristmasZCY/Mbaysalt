% spiral demo10
% ----------------------
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer 

figure('Units','normalized', 'Position',[.1,.1,.6,.75])

% Create spiral-axes
SS1 = SSpiral(gca);
SS1.set('TLim',[0,2*360+180], 'XLim',[0,100]+.5, 'YLim',[0,1], 'XTick',0:5:200)  

X = 1:100;
Y1 = rand(1,100);
Y2 = rand(1,100);
SS1.bar(X-.25,Y1,'BarWidth',.5);
SS1.bar(X+.25,Y2,'BarWidth',.5);

legend({'AAA','BBB'}, 'FontSize',12, 'FontName','Times New Roman')


% =========================================================================


figure('Units','normalized', 'Position',[.1,.1,.6,.75])
% Create spiral-axes
SS2 = SSpiral(gca);
SS2.set('TLim',[0,2*360+180], 'XLim',[0,100]+.5, 'YLim',[0,1], 'XTick',0:5:200)  

X = 1:100;
Y1 = rand(1,100);
Y2 = rand(1,100);
Y3 = rand(1,100);
SS2.bar(X-.25,Y1,'BarWidth',.25);
SS2.bar(X,Y2,'BarWidth',.25);
SS2.bar(X+.25,Y3,'BarWidth',.25);

legend({'AAA','BBB','CCC'}, 'FontSize',12, 'FontName','Times New Roman')