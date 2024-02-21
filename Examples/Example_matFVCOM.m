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
g4 = f_2d_mesh(f,'Global');
% g4 = f_2d_lonlat(f);
g5 = f_2d_mask_boundary(f);
clf
g6 = f_2d_cell(f,1:1400);
% g7 = f_2d_range(f,'Coordinate','geo');
g7 = f_2d_contour(f,zeta(:,1),'Manual','NoLabel','Global');
g8 = f_2d_vector(f,u(:,1,1),v(:,1,1),'Vh',0.1,'List',[1:f.nele]);
g9 = f_2d_vector2(f,u(:,1,1),v(:,1,1));
% f_2d_vector3(f,u(:,1,1),v(:,1,1));

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

%% FVCOM river netCDF
clm
ncload /Users/christmas/Documents/Code/Project/Server_Program/ForecastModel/温州182/input/WenZhou_river.nc
clear Itime Itime2 Times time
river_names = cellstr(river_names);
time = f_load_time('/Users/christmas/Documents/Code/Project/Server_Program/ForecastModel/温州182/input/WenZhou_river.nc');
write_river('./Wenzhou_river_20230101_20261231.nc', ...
    cellstr(river_names), time, ...
    'Temperature',river_temp', 'Salinity',river_salt', 'Flux',river_flux');

