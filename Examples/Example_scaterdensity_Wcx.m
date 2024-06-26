clm
load n.txt
tem_fore=n(:,2);
tem_obs=n(:,1);

% Use Kernel smoothing function to get the probability density estimate (c)
c = ksdensity([tem_fore,tem_obs], [tem_fore,tem_obs]);
MarkerSize=50;  % 点的半径
h = scatter(tem_fore, tem_obs, MarkerSize, c,  'filled');
colormap;
cb = colorbar();
cb.Label.String = 'Probability density estimate';
hold on

set(gca,'Xlim',[0,4],'Ylim',[0,4],'XTick',0:0.5:4,'YTick',0:0.5:4)
h1 = refline(1,0); % 辅助1:1线
h2 = refline(); % 拟合线获取
set(h1,'color','black','linewidth',1.5)
set(h2,'color','red','linewidth',1.5)
set(gca,'Xlim',[0,4],'Ylim',[0,4],'XTick',0:0.5:4,'YTick',0:0.5:4)
set(get(gca,'YLabel'),'FontSize',16,'FontName','Times New Roman');
set(gcf,'color','white','paperpositionmode','auto');
set(gca,'FontName','Times New Roman','FontSize',16,'fontweight','bold');
xlabel('forecast model','Fontname', 'Times New Roman','FontSize',16);
ylabel('WOD obervation','Fontname', 'Times New Roman','FontSize',16);
box on;

txt_set = {'FontName','Times New Roman','FontSize',15,'fontweight','bold'};
p = polyfit(tem_fore,tem_obs,1);
% [s,c] = fit(tem_fore,tem_match,'poly1')

S = calc_validation(tem_fore, tem_obs);
text(.5,3.5,['y = ' num2str(p(1)) '*X' num2str(p(2),'%+f')],txt_set{:})
text(.5,3.4,['R=',num2str(S.R,'%.2f')],txt_set{:})
text(.5,3.3,['Bias=',num2str(S.Bias,'%.4f')],txt_set{:})
text(.5,3.2,['MAE=', num2str(S.MAE,'%.4f')],txt_set{:})
text(.5,3.1,['RMSE=',num2str(S.RMSE,'%.4f')],txt_set{:})
set(text,'FontName','Times New Roman','FontSize',16,'fontweight','bold');

%% scatplot
X = [tem_fore, tem_obs];
scatplot(X(:,1),X(:,2),'circles');
hold on
plot([0,40],[0,40],'r','linewidth',1.5)
hold on
b = polyfit(tem_obs,tem_fore,1);%进行1次拟合
yy = polyval(b,tem_obs);%得到拟合后y的新值
plot(tem_obs,yy,'k','linewidth',1.5)%画拟合图
colormap jet

 
