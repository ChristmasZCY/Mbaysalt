% spiral demo5
% ----------------------
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer 

% area diagram on spiral-axes
% ============================
% default properties:
% ----------------------------
% EdgeColor = 'none';
% FaceAlpha = .5;
% EdgeAlpha = 1;
% LineWidth = .5;
% ----------------------------

% area diagram on spiral-axes
figure('Units','normalized', 'Position',[.1,.1,.6,.75])
SS1 = SSpiral(gca);
SS1.set('TLim',[0,2*360+180], 'XLim',[1,200], 'YLim',[0,1], 'XTick',0:5:200)  
Y = rand(200,1);
SS1.area(1:200,Y);


% =========================================================================
% area diagrams on spiral-axes
figure('Units','normalized', 'Position',[.1,.1,.6,.75])
SS2 = SSpiral(gca);
SS2.set('TLim',[0,2*360+180], 'XLim',[1,200], 'YLim',[0,1], 'XTick',0:5:200)  
Y = rand(200,2);
SS2.area(1:200,Y(:,1));
SS2.area(1:200,Y(:,2));


% =========================================================================
% Different colors in the positive and negative parts
figure('Units','normalized', 'Position',[.1,.1,.6,.75])
SS3 = SSpiral(gca);
SS3.set('TLim',[0,2*360+180], 'XLim',[1,200], 'YLim',[-.5,.5], 'XTick',0:5:200)  
Y = rand(200,1)-.5;
Y = interp1(1:200, Y ,(1:.1:200).');
SS3.area(1:.1:200,Y.*(Y>0));
SS3.area(1:.1:200,Y.*(Y<0));


% =========================================================================
% 堆叠面积图
% stacked-area diagram
figure('Units','normalized', 'Position',[.1,.1,.6,.75])
SS4 = SSpiral(gca);
SS4.set('TLim',[0,2*360+180], 'XLim',[1,200], 'YLim',[0,1.8], 'XTick',0:5:200)  
Y = rand(200,2);
SS4.area(1:200,Y);
legend({'AAA','BBB'}, 'FontSize',12, 'FontName','Times New Roman')



% =========================================================================
% 含有负数的堆叠面积图
% Containing negative numbers stacked-area diagram
figure('Units','normalized', 'Position',[.1,.1,.6,.75])
SS5 = SSpiral(gca);
SS5.set('TLim',[0,2*360+180], 'XLim',[1,200], 'YLim',[-1,1], 'XTick',0:5:200)  
Y = rand(200,2)-.5;
Y = interp1(1:200, Y ,1:.1:200);
SS5.area(1:.1:200,Y);