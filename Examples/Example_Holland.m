clm

% 读取台风数据
[lon0, lat0, Ttimes1, pre0] = read_tcdata_typhoon('TYP.txt'); % https://tcdata.typhoon.org.cn/zjljsjj.html
yeari = Ttimes1.Times.Year;
monthi = Ttimes1.Times.Month;
dayi = Ttimes1.Times.Day;
houri = Ttimes1.Times.Hour;
time0 = Ttimes1.datenumC;
t_start = time0(1);
t_end = time0(end);

% 读取ERA5风场数据
[GridStruct, VarStruct, Ttimes2] = c_load_model('2013ERA5wind.nc','Coordinate','geo');
Lon = GridStruct.x; lon = GridStruct.x1D;
Lat = GridStruct.y; lat = GridStruct.y1D;
time_era = Ttimes2.datenumC;
F = find((time_era>=t_start)&(time_era<=t_end));
time_lap = time_era(F);
u10 = VarStruct.u10(:,:,F);
v10 = VarStruct.v10(:,:,F);
% 统一时间分辨率
Lon_tyCenter= interp1(time0,lon0,time_lap);
Lat_tyCenter= interp1(time0,lat0,time_lap);
P0_tyCenter= interp1(time0,pre0,time_lap);
Ttimes3 = Mdatetime(time_lap,'Cdatenum');

[UV_center, uE, vN] = calc_typhoonMove(Lon_tyCenter, Lat_tyCenter, Ttimes3.Times);
[Uh, Vh, c] = calc_windHolland(Lon, Lat, Lon_tyCenter, Lat_tyCenter, UV_center, P0_tyCenter, uE, vN);  % Holland wind UV
[Uc, Vc] = calc_overlayWind(Uh, Vh, u10, v10, c, 'method', '0814');  % Superimposed wind UV
contourf(calc_uv2wind(u10(:,:,1),v10(:,:,1))-calc_uv2wind(Uc(:,:,1),Vc(:,:,1)),10)

function [lon, lat, Ttimes, pres] = read_tcdata_typhoon(fin)
    data0=importdata(fin);
    t0=num2str(data0(:,1));
    Ttimes = Mdatetime(t0,"fmt",'yyyyMMddHH');
    lon = data0(:,4)/10;
    lat = data0(:,3)/10;
    pres =data0(:,5);
end
