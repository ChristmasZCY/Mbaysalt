%% 频数直方图
clm
x = readmatrix('sst.csv');
y = x(2:end,2);
histogram(y, 'Normalization', 'probability', 'FaceColor', [1 0.27 0.0], 'EdgeColor', [1 1 1], 'FaceAlpha', 0.5); % 画出频率直方图
xlabel('variable'); % 设置x轴标签
ylabel('Frequency'); % 设置y轴标签
set(gca,'FontSize',16); % 设置坐标轴字体大小

%% 云雨图
clm
pathFigure= '.\Figures\' ;
figureUnits = 'centimeters';
figureWidth = 20;
figureHeight = 10;

%% 绘制横向云雨图
x = readmatrix('sst.csv');
x = x(2:end,2);
rainCloudsH({x}, {'A'})

% str= strcat(pathFigure, "图1 "+"横向云雨图", '.tiff');
% print(gcf, '-dtiff', '-r600', str);
%% 调用函数

function rainCloudsH(dataCell, dataName)

% 颜色列表
colorList=[0.9294    0.7569    0.5059
    0.9176    0.5569    0.4627
    0.7020    0.4784    0.5451
    0.4863    0.4314    0.5490];
% =========================================================================

classNum=length(dataCell);
if size(colorList,1)==0
    colorList=repmat([130,170,172]./255,[classNum,1]);
else
    colorList=repmat(colorList,[ceil(classNum/size(colorList,1)),1]);
end
if isempty(dataName)
    for i=1:classNum
        dataName{i}=['class',num2str(i)];
    end
end

figure(1)
% 坐标区域修饰
hold on; box on;
ax=gca;
ax.YLim=[1/2,classNum+2/3];
ax.YTick=1:classNum;
ax.LineWidth=1.2;
ax.YTickLabels=dataName(end:-1:1);
ax.FontSize=14;

rate=3.5;

% 绘制雨云图
for i=1:classNum
    tX=dataCell{i};tX=tX(:);
    [F,Xi]=ksdensity(tX);

    % 绘制山脊图
    patchCell(i)=fill([Xi(1),Xi,Xi(end)],0.2+[0,F,0].*rate+(classNum+1-i).*ones(1,length(F)+2),...
        colorList(i,:),'EdgeColor',[0,0,0],'FaceAlpha',0.8,'LineWidth',1.2);
    % keyboard
    % 其他数据获取
    qt25=quantile(tX,0.25); % 下四分位数
    qt75=quantile(tX,0.75); % 上四分位数
    med=median(tX);         % 中位数

    outliBool=isoutlier(tX,'quartiles');  % 离群值点
    nX=tX(~outliBool);                    % 95%置信内的数

    % 绘制箱线图
    plot([min(nX),max(nX)],[(classNum+1-i),(classNum+1-i)],'k','lineWidth',1.2);
    fill([qt25,qt25,qt75,qt75],(classNum+1-i)+[-1 1 1 -1].*0.12,colorList(i,:),'EdgeColor',[0 0 0]);
    plot([med,med],[(classNum+1-i)-0.12,(classNum+1-i)+0.12],'Color',[0,0,0],'LineWidth',2.5)

    % 绘制散点
    tY=(rand(length(tX),1)-0.5).*0.24+ones(length(tX),1).*(classNum+1-i);
    scatter(tX,tY,15,'CData',colorList(i,:),'MarkerEdgeAlpha',0.15,...
        'MarkerFaceColor',colorList(i,:),'MarkerFaceAlpha',0.1)
end

set(gca,'FontName','Times New Roman','FontSize',14, 'Layer','top','LineWidth',1);

% 绘制图例
hl = legend(patchCell,dataName);
set(hl,'Box','off','location','northOutside','NumColumns',4,'FontSize',16,'FontName','Times New Roman');

end



