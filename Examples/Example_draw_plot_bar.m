clm
YData1 = [1132, 1454, 1147, 752;959, 1498, 1244, 1043;1264, 1510, 1283, 879;
1300, 1446, 1117, 1090; 901, 1435, 1378, 777; 1047, 1380, 975, 947
798, 1214, 1057, 866; 947, 1079, 1089, 624];
q_sum = [1534;1587;1590;1590;1568;1520;1424;1368];
year = (2013:2020)';


figure('Position',[500,200,850,550])

% 原图片配色(matlab要求配色范围0-1因此要除以255)
CData=[111,173,72;92,154,215;255,192,1;69,103,42;36,94,144]./255;

% -------------------------------------------------------------------------
% 上子图
ax1 = subplot(2,1,1);hold on
hBar1 = bar(YData1);
ax2 = subplot(2,1,2);hold on
p2 = plot(q_sum);
for i = 1:length(year)
    text(i, q_sum(i), num2str(q_sum(i)), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'FontSize', 9, 'FontName', 'Times New Roman', ...
        'Color', 'blue');
end
% -------------------------------------------------------------------------
% 分组柱状图修饰
for i=1:length(hBar1)
    hBar1(i).EdgeColor='none';      % 轮廓无色
    hBar1(i).FaceColor=CData(i,:);  % 设置颜色
end
% -------------------------------------------------------------------------
% 修改X轴标签文本
ax1.XTick=1:size(YData1,1);
ax1.XTickLabel=year;
ax2.XTick=1:size(YData1,1);
ax2.XTickLabel=year;

ylabel(ax1, '渔区数量/个', 'FontName', '宋体', 'FontSize', 10.5, 'FontWeight', 'bold')
ylabel(ax2, '渔区数量/个', 'FontName', '宋体', 'FontSize', 10.5, 'FontWeight', 'bold')
xlabel(ax2,'年渔区数量变化趋势','FontName', '宋体', 'FontSize', 10.5, 'FontWeight', 'bold');

% 修改坐标区域字体
ax1.FontName='songti';
ax1.FontWeight='bold';
ax1.FontSize=12;
ax2.FontName='songti';
ax2.FontWeight='bold';
ax2.FontSize=12;
% 添加网格并修饰
ax1.XGrid='on';
ax1.GridAlpha=.2;
ax2.XGrid='on';
ax2.GridAlpha=.2;
% 框修饰
ax1.Box='on';
ax1.LineWidth=1.5;
ax2.Box='on';
ax2.LineWidth=1.5;
% 刻度长度设置为0
ax1.TickLength=[0,0];
ax2.TickLength=[0,0];
% -------------------------------------------------------------------------
% 绘制辅助线
XV=(1:size(YData1,1)-1)+.5;
for i=1:length(XV)
    xline(ax1,XV(i),'LineWidth',1.4,'LineStyle','--','Color',[0,0,0]);
end 
% -------------------------------------------------------------------------
% 添加图例
lgd1=legend(hBar1,'第一季度','第二季度','第三季度','第四季度','FontSize',13);

% 设置图例位置
lgd1.Location='southoutside';

% 设置图例横向排列
lgd1.NumColumns=length(hBar1);

% 设置图例方形大小
lgd1.ItemTokenSize=[8,8];

% 关闭框
lgd1.Box='off';
% -------------------------------------------------------------------------
% print('fig3-3','-dpng','-r600');

