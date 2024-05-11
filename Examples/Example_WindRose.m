% Description:
%       Siqi Li :   https://mp.weixin.qq.com/s/dqXBBeYBlbq-ESBzgUDYvw
%
% 浮标数据： 
%       https://www.ndbc.noaa.gov/station_history.php?station=44020
% 各语言中风玫瑰图的相关命令介绍：
%       https://www.ncl.ucar.edu/Applications/rose.shtml
%       https://pypi.org/project/windrose/
%       https://www.rdocumentation.org/packages/openair/versions/2.7-2/topics/windRose
%       https://dpereira.asempyme.com/windrose/
%%
clm
u = nr('/Users/christmas/Desktop/exampleNC/wind_5.nc','wind_U10');
v = nr('/Users/christmas/Desktop/exampleNC/wind_5.nc','wind_V10');
[spd, dir] = calc_uv2wind(u,v);
Options = {'anglenorth',0,...
'angleeast',90,...
'labels',{'N (0^o)','NE (45^o)','E (90^o)','SE (135^o)','S (180^o)','SW (225^o)','W (270^o)','NW (315^o)'},...
'freqlabelangle','auto',...
'MaxFrequency',6,...
'nFreq',6,...
'vWinds',[0 4 8 12 16],...
'LabLegend','Wind Speed (m/s)',...
'legendtype',2,...
'titlestring',''};
[figure_handle,count,speeds,directions,Table] = WindRose(dir,spd,Options);

%% subplot
figure('color','w')
Options = {'anglenorth',0,... 
           'angleeast',90,...
           'labels',{'','E','S','W'},...
           'freqlabelangle','auto',...
           'min_radius',0.25,...
           'vWinds',[0 4 8 12 16],...
           'MaxFrequency',8,...
           'nFreq',4,...
           'LabLegend','Wind Speed (m/s)',...
           };
[figure_handle,count,speeds,directions,Table] = WindRose(dir, spd,[Options,{'titlestring','Spring'},{'legendtype',2},{'axes',subplot(2,2,1)}]);
[figure_handle,count,speeds,directions,Table] = WindRose(dir, spd,[Options,{'titlestring','Summer'},{'legendtype',0},{'axes',subplot(2,2,2)}]);
[figure_handle,count,speeds,directions,Table] = WindRose(dir, spd,[Options,{'titlestring','Autumn'},{'legendtype',0},{'axes',subplot(2,2,3)}]);
[figure_handle,count,speeds,directions,Table] = WindRose(dir, spd,[Options,{'titlestring','Winter'},{'legendtype',0},{'axes',subplot(2,2,4)}]);
