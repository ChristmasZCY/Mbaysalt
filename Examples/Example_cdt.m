%% CDT
borders('countries','color',rgb('dark gray'))  % 岸线
cmocean thermal  % colorbar
[latout,lonout,ustd,vstd] = recenter(G.y1D,G.x1D,V.u_std,V.v_std,'center',180) ;   % 更改中心经纬度
quiversc(lon,lat,u10,v10)  % 自动缩放箭头
cbarrow  % colorbar
bordersm('countries','color',rgb('dark gray'))  % 岸线
cbdate
earthimage('center',0)
globeborders
