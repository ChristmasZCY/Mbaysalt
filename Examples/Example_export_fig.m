%% print
print(gcf, 'test.png','-r300','-dpng');
print('BarPlot','-dpng');%将绘图另存为 BarPlot.png
print('-clipboard','-dmeta') %图窗复制到剪贴板
print('BarPlot','-depsc');%print 将绘图另存为 BarPlot.eps。
print('SurfacePlot','-depsc','-tiff');%将当前图窗另存为封装的 PostScript 文件并添加 TIFF 预览。
print('-f2','MySavedPlot','-dpng');%保存图窗并在标题栏中显示 Figure 2。在整数值前面加上 -f。
set(gcf,'PaperPositionMode','auto');
print('PeaksSurface','-dpng','-r0');%将图窗的 PaperPositionMode 属性设置为 'auto' 以使其保存为屏幕上显示的大小。使用 '-r0' 可按屏幕分辨率保存它。
print('FillPageFigure','-dpdf','-fillpage'); %使用 '-fillpage' 选项保存填满页面的图窗。

%% export_fig
export_fig 1.png -r300; %默认消除了白边
export_fig test.png –r300 –nocrop; %不消除白边
export_fig D:\test.tif -r300
export_fig D:\test.tif -r300 –painters; %对于虚线、点线变密问题
export_fig -m<放大倍数>
export_fig –r<每英寸像素个数>
export_fig test.png -m2.5
name1=['../pic/',year,'总产量.png'];
eval(['export_fig ' name1]) % %循环出图
%% exportgraphics 图片
exportgraphics(gcf,'peaks.png','Resolution',300);%输出分辨率为300的PNG图片
exportgraphics(gcf,'peaks.pdf','ContentType','vector');%输出矢量pdf图片
exportgraphics(gcf,'peaks.eps');%输出矢量eps图片
