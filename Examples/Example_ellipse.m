%  <a href="matlab: web('https://www.bilibili.com/read/cv1265059/')">tidal ellipse</a>.
% 为了强调画图，我就先编几个潮流调和常数，假定第一个椭圆的长半轴是1，短轴是0.5，倾角是45°；第二个椭圆的三个值是1.2，-0.3和90°。代码如下：

clm 
%this program is used to draw tidal ellipse
%is a beta version
%need t_tide, m_map, and ellipse2.m, all of these is open source and free
%to available

%% read elliptic elements
strds= 70;%the standard radius
ra = [1,1.2];%major axis of ellipse
rb = [0.5,-0.3];%minor axis
ang = [pi/4,pi/2];%inclinic angle
lon = [126,125];
lat = [29,30];
%% draw ellipse on the map
m_proj('miller','lon',[120,132],'lat',[24,34]);
for i = 1:2
    [llx,lly] = m_ll2xy(lon(i),lat(i),'clip','off'); % 跳出了m_map，让m_map先当一会背景画板
    if rb(i) > 0
        ellipse(abs(ra(i))/strds,abs(rb(i))/strds,ang(i),llx,lly,'r-');
    elseif  rb(i) < 0
        ellipse(abs(ra(i))/strds,abs(rb(i))/strds,ang(i),llx,lly,'b-');
    end
    hold on;
end
m_gshhs_l('patch',[.7 .7 .7],'edgecolor','k');
m_grid('linest','none','box','on','xtick',9);
