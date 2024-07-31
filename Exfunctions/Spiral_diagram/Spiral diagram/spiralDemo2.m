% spiral demo2
% ----------------------
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer 

% bar diagram on spiral-axes
% ============================
% default properties:
% ----------------------------
% EdgeColor = [0,0,0];
% FaceAlpha = 1;
% EdgeAlpha = 1;
% LineWidth = .5;
% BarWidth = 1;
% ----------------------------

figure('Units','normalized', 'Position',[.1,.1,.6,.75])

% Create spiral-axes
SS1 = SSpiral(gca);
SS1.set('TLim',[0,2*360+180], 'XLim',[0,200]+.5, 'YLim',[0,1], 'XTick',0:5:200)  

X = rand(1,200);
SS1.bar(X);
SS1.bar(X./2);
SS1.bar(X./4);

legend({'AAA','BBB','CCC'}, 'FontSize',12, 'FontName','Times New Roman')




% =========================================================================
figure('Units','normalized', 'Position',[.1,.1,.6,.75])

% Create spiral-axes
SS2 = SSpiral(gca);
SS2.set('TLim',[0,2*360+180], 'XLim',[0,200]+.5, 'YLim',[-.5,.5], 'XTick',0:5:200)  

X = rand(1,200) - .5;
X1 = X.*(X>0);
X2 = X.*(X<0);
SS2.bar(X1);
SS2.bar(X2);

legend({'AAA','BBB'}, 'FontSize',12, 'FontName','Times New Roman')


