%% FVCOM
fin = '/Users/christmas/Desktop/exampleNC/forecast_0001.nc';
f = f_load_grid(fin,'Coordinate','geo');

f2dm = '/Users/christmas/Desktop/项目/网格/FVCOM全球/Global-FVCOM_v1.1.2dm';
f = f_load_grid(f2dm,'MaxLon',360);

zeta = nr(fin,'zeta');
u = nr(fin,'u');
v = nr(fin,'v');

%% f_2d
g1 = f_2d_image(f,zeta(:,1));
hold on
g2 = f_2d_boundary(f);
g3 = f_2d_coast(f,'Coordinate','geo','Resolution','l');
% f_2d_coast(f,"New")
g4 = f_2d_mesh(f,'Global');
% g4 = f_2d_lonlat(f);
g5 = f_2d_mask_boundary(f);
clf
g6 = f_2d_cell(f,1:1400);
% g7 = f_2d_range(f,'Coordinate','geo');
g7 = f_2d_contour(f,zeta(:,1),'Manual','NoLabel','Global');
[g8,para] = f_2d_vector(f,u(:,1,1),v(:,1,1),'Vh',0.1,'List',[1:f.nele]);
f_2d_vector_legend(f, 119.46, 34.73, 1, 0,'1 m/s',para)
g9 = f_2d_vector2(f,u(:,1,1),v(:,1,1));
% f_2d_vector3(f,u(:,1,1),v(:,1,1));

%% f calculate
S = calc_area(x(nv), y(nv), 'R', R, Geo);  % tri-area


%% Global
draw_global_ortho.m

%% WRF
win = '/Users/christmas/Desktop/exampleNC/d01.nc';
w = w_load_grid(win);
t2 = nr(win,'T2');

close
g1 = w_2d_coast(w);
hold on
g2 = w_2d_boundary(w);
g4 = w_2d_contour(w,t2(:,:,1),'Manual','NoLabel');
g5 = w_2d_image(w,t2(:,:,1),'Global');
g6 = w_2d_mask_boundary(w);
g7 = w_2d_mesh(w);
g8 = w_2d_range(w);
g9 = w_2d_vector(w);
g9 = w_2d_vector_legend(w);

%% KML
kml_w_boundary()
kml_f_boundary()
kml_f_mesh()

%% calculate resolution
% f = f_load_grid('/Users/christmas/Desktop/项目/网格/田湾核电/v4.1/tw_utm4.2dm');
% [d_cell, d] = f_calc_resolution(f);
f = f_load_grid('/Users/christmas/Desktop/项目/网格/田湾核电/v4.1/tw_lon_lat4.2dm','Coordinate','xy');
[d_cell, d] = f_calc_resolution(f,'Geo');
f_2d_image(f,d_cell)

%% Get netsing
clm
fgrid = f_load_grid('/Users/christmas/Desktop/exampleNC/FVCOM_ECS_2d.nc','Coordinate','geo');
[node_layer, cell_layer, weight_node, weight_cell] = f_find_nesting(fgrid, 1:102, 1);
node_nesting = [node_layer{:}];
cell_nesting = [cell_layer{:}];
node_weight = [weight_node{:}];
cell_weight = [weight_cell{:}];
fn = f_load_grid_nesting(fgrid, node_nesting, cell_nesting);
f_2d_mesh(fn)

%% Add sigma for fgrid
clm
fgrid = f_load_grid('/Users/christmas/Desktop/项目/网格/温州/2022-李思齐一期182/WenZhou_Dep1+.2dm');
sigma = read_sigma('/Users/christmas/Desktop/项目/网格/温州/2022-李思齐一期182/WenZhou_sigma.dat');
fgrid1 = f_calc_sigma(fgrid, sigma);
draw_sigma(sigma)

%% FVCOM river netCDF
clm
ncload /Users/christmas/Documents/Code/Project/Server_Program/ForecastModel/温州182/input/WenZhou_river.nc
clear Itime Itime2 Times time
river_names = cellstr(river_names);
time = f_load_time('/Users/christmas/Documents/Code/Project/Server_Program/ForecastModel/温州182/input/WenZhou_river.nc');
write_river('./Wenzhou_river_20230101_20261231.nc', ...
    cellstr(river_names), time, ...
    'Temperature',river_temp', 'Salinity',river_salt', 'Flux',river_flux');

%% Extract coastline and write
f = f_load_grid('/Users/christmas/Desktop/项目/网格/北部湾/v3/Beihai(lonlat3).2dm');
a = [];
b = [];
for i = 1:length(f.bdy_x)
    a = [a,f.bdy_x{i},NaN];
    b = [b,f.bdy_y{i},NaN];
end
% plot(a,b)
write_cst('/Users/christmas/Desktop/x.cst', a,b)

%% Merge nodestrings
f = f_load_grid("C:\Users\christmas\Desktop\WZAJinu.2dm");
ns = horzcat(f.ns{:});
f.h(ns) = 6.8;

%% 飓风路径的计算和数据下载 https://mp.weixin.qq.com/s/xlulz-Mm0ZvKaTpoWWw_lQ
% slp = f(P, PB, T, QVAPOR, PH, PHB)
% slp = calc_slp(T, QVAPOR, pres, gp);
% pres = P + PB;
% gp = PH + PHB;

%% draw satellite
fin = '/Users/christmas/Documents/Code/Project/Server_Program/ModelGrid/温州/2022-李思齐一期182/WenZhou_Dep1+.2dm';
f = f_load_grid(fin);
bm = basemap_read(minmax(f.x),minmax(f.y));
hold on
basemap_plot(bm)
f_2d_mesh(f)

%% change ncfile
ftime = f_load_time(fin,"Times");
[time, Itime, Itime2, Times] = convert_fvcom_time(ftime+366);
ncwrite(fin,'time',time); 
ncwrite(fin,'Itime',Itime);
ncwrite(fin,'Itime2',Itime2); 
ncwrite(fin,'Times',Times');

%% wite station
clm
fin = '/Users/christmas/Documents/Code/Project/Server_Program/CalculateModel/FVCOM_WZtide3/Control/data/wztide3.2dm';
f = f_load_grid(fin);
write_station('sta.txt', 'sta2.txt', f, [121.145,121.1033333],[27.85833333,28.18], 'Name',["DONGTOU" "SHAGANGTOU"],'Depth',[0 0])
