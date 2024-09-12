
%% 科氏力
f = sw_f(lat);

%% 两个经纬度坐标之间的距离
[dist,phaseangle] = sw_dist(lat,lon,units); 

%% 比体积异常
svan = sw_svan(S,T,P);

%% 计算相对于指定的水质量的潜在密度
pden = sw_pden(S,T,P,PR);
