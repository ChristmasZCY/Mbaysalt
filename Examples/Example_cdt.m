%% CDT
borders('countries','color',rgb('dark gray'))  % 岸线
cmocean thermal  % colorbar
[latout,lonout,ustd,vstd] = recenter(G.y1D,G.x1D,V.u_std,V.v_std,'center',180) ;   % 更改中心经纬度
quiversc(lon,lat,u10,v10)  % 自动缩放箭头
cbarrow  % colorbar
bordersm('countries','color',rgb('dark gray'))  % 岸线
cbdate % 将颜色条刻度格式为日期字符串。
earthimage('center',0)
globeborders
globeimage  % 创建一个“蓝色大理石”三维地球图像。
borders  % 边界绘制国家或美国国家边界没有matlab的映射工具箱。如果您想在由matlab的映射工具箱生成的地图上绘制边界，请使用bordersm。

%% xyz file
[x,y,z] = xyzread('Curie_Depth.xyz');
[X,Y,Z] = xyz2grid(x,y,z);
pcolor(X,Y,Z)
shading flat

%% 创建一个纬度和经度的全球网格
[lat,lon] = cdtgrid;

%% dist2coast 决定了从任何地理位置到最近海岸线的距离

%% textcolorbar 函数创建一个颜色缩放的文本，它介于颜色栏和文本图例之间。它不会劫持当前的颜色图。

%% imagescn imagescn的行为就像imagesc，但使na ns透明，如果包含xdata和ydata，则将轴设置为xy，并且比imagesc有更多的错误检查。

%% globe
% globeimage creates a "Blue Marble" 3D globe image.
% globeplot function plots georeferenced data on a globe.
% globepcolor georeferenced data on a globe where color is scaled by the data value.
% globesurf plots georeferenced data on a globe where values in matrix Z are plotted as heights above the globe.
% globecontour plots contour lines on a globe from gridded data.
% globescatter plots georeferenced data as color-scaled markers on a globe.
% globeborders plots political boundaries borders on a globe.
% globequiver plots georeferenced vectors with components (u,v) on a globe.
% globestipple creates a hatch filling or stippling over a region of a globe.
% globegraticule plots a graticule globe. Optional inputs control the appearance and behavior of the graticule.
% globefill plots a filled globe.

%% nc
A = ncstruct(fin);
A = ncdatelim(fin,'time');

%% near1
row = near1(lat,23);

%% datetick
datetick()

%% deseason
sst_ds = deseason(sst,t);

%% trend
trend(sst,12)

%% cmocean
cmocean('thermal')
cmocean('balance','pivot')

%% stipple 点画在网格内创建一个hatch填充或点画。该函数主要用于显示空间地图中具有统计意义的区域
stipple
