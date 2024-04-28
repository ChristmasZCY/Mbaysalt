# t-tide软件包使用说明

t-tide软件包可能会受到Matlab和工具包版本影响（t-tide软件包下载地址https://www.eoas.ubc.ca/~rich/#T_Tide）

t-tide软件包主要用于验潮站潮位资料的调和分析和预报。其中t_tide.m用于分析，t_predic.m用于潮汐预报。其主要操作流程为：

1、数据预处理。主要是对数据缺测值的处理，不同的数据中缺测值的表示方式不同，t-tide使用前采用将缺测值内插或者用NaN代替的方式。
2、程序实现：
    <img src="./pics/t_tide_1.png" width="50%">>

前两步是数据读取，目的是为了将原始数据一列的读取在变量tt中。第三步为t-tide的使用，一般情况下将数据的起始时间和纬度放置于t-tide中即可满足要求。此程序针对的是逐时潮位资料，即数据时间间隔为1h，当数据间隔时间不为1h时，可按照t-tide.m中的介绍修改即可。nameu, fu, tidecon用于潮汐预报。

3、潮汐预报。潮汐预报的运行是在调和分析结束后进行的，程序为：
    <img src="./pics/t_tide_2.png" width="50%">

这时，计算的变量yout即为不含计算数据平均值的预报潮位。

4、潮流调和分析

```MATLAB
[nameu, fu, tidecon xout]=t_tide(zeta(实数)或u+iv（虚数），0.5（小时数），'output','tide_e.dat');
% xout tidal flow/elevations
```

noise=原始时间序列-xout; （余流residule）
注意：时间序列必须等间距（此处0.5hr）

**注**：

如果做潮流调和分析的话，也类似，只不过一开始就要通过U+sqrt(-1)*V把U,V两个方向的数据合并成一个复数数组（U为东，V为北）。输出参数介绍：

major为分潮流最大流速，minor为最小流速（潮流矢量随着时间顺时针转时minor为负)，inc椭圆旋转方向（即正北方顺时针旋转的度数），pha对应长轴上的迟角。

这里各个分潮的频率的单位都是cph，如果要换成HZ的话，需要除3600.

如何画潮流椭圆的程序，
    
```MATLAB
function lemax=tidal_ellipse(uam,uph,vam,vph,omega,depth,color)
% 单一站点垂向潮流椭圆（2014-8-27）
% 专用于本次观测的数据
% uam：流速u的振幅
% uph：流速u的迟角
% vam：流速v的振幅
% vph：流速v的迟角
% omega：对应分潮的角频率(M2:1.4050789e-4;S2:1.4544410e-4;K1:7.2921161e-5;O1:6.7597750e-5)
% depth：对应的水深
% color：潮流椭圆的颜色
t=[0:300:36*3600];
u=uam*cos(omega*t-uph/180*pi);
v=vam*cos(omega*t-vph/180*pi);
L=sqrt(u.^2+v.^2);
Lmax=max(L);
lemax = max(Lmax)
Lmin=min(L);
pmax=find(L==Lmax);
pmin=find(L==Lmin);
plot(u,depth+v,'color',color,'linewidth',1.5);
hold on
```
