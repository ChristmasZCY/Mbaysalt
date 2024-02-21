%%
% ESMF 线性插值最好用 earth system model framework
% meshgrid: [Lat,Lon] = meshgrid(Lat,Lon); Lat 放在前面
% knnsearch == KDTreeSearcher
% lonc latc 球面坐标
% interp_3d_* 先vertically interpolate, then horizontally interpolate， then vertically interpolate

% node-网格点 temp salt zeta
% cell-重心点 u v

% level-层面  siglay kb
% layer-层心  siglev kbm1

%%
ncfile = '/data/ForecastSystem/Output/FVCOM_Global/20230313/forecast/forecast_0001.nc';
% msh = '/home/ocean/ForecastSystem/FVCOM_Global/Postprocess/Global-FVCOM_v1.1.2dm'

u = double(ncread(ncfile, 'u'));
v = double(ncread(ncfile, 'v'));
temp = double(ncread(ncfile,'temp'));


% Read in the 2dm file
f_nc = f_load_grid(ncfile,'Coordinate','geo');
f_2dm = f_load_grid(msh);

% Destination grid
Lon = 0:360;
Lat = -90:90;
[Lat,Lon] = meshgrid(Lat,Lon);

% Calculate the interpolation weights
weight = interp_2d_calc_weight('TRI',f_nc.LON,f_nc.LAT,f_nc.nv,Lon,Lat);

% Interpolate u data
u_int = f_interp_cell2node(f_nc, u);

% Cell -> node
u2 = interp_2d_via_weight(u_int,weight);

% Interpolate temperature data
temp2 = interp_2d_via_weight(temp,weight);

%% Interpolate vertical data fvcom grid
weight = interp_vertical_calc_weight(f_nc.deplay,repmat([2 4 8 10 15 200],f_nc.node,1));

for it = 1:size(temp,3)
    tV(:,:,it) = interp_vertical_via_weight(temp(:,:,it),weight);
end

%% 3d
std = 0:1:110;
weight_node = interp_2d_calc_weight('TRI',f1.x,f1.y,f1.nv,fn.x,fn.y);
weight_node_siglay = interp_3d_calc_weight(f1.deplay, std, fn.deplay,'TRI', f1.x, f1.y, f1.nv, fn.x, fn.y, 'Extrap');
weight_cell_siglay = interp_3d_calc_weight(f1.deplayc, std, fn.deplayc,'TRI', f1.xc, f1.yc, f1.nv, fn.xc, fn.yc, 'Extrap');

zeta = interp_2d_via_weight(zeta0(:,it), weight_node);
temp = interp_3d_via_weight(temp0(:,:,it), weight_node_siglay);
salinity = interp_3d_via_weight(salinity0(:,:,it), weight_node_siglay);
u = interp_3d_via_weight(u0(:,:,it), weight_cell_siglay);
v = interp_3d_via_weight(v0(:,:,it), weight_cell_siglay);

%% vertical 2d
f1 = f_load_grid(fin);
weight.v = interp_vertical_calc_weight(f1.deplay,repmat(std,f1.node,1));
weight.h = interp_2d_calc_weight('TRI',f1.x,f1.y,f1.nv,f2.x,f2.y);

temp0 = ncread(fin, 'temp', [1 1 it], [Inf Inf 1]);
% tsl = interp_3d_via_weight(weight_node_siglay, temp0);
tsl = interp_vertical_via_weight(temp0, weight.v);
tsl = interp_2d_via_weight(tsl, weight.h);
% salinity
salinity0 = ncread(fin, 'salinity', [1 1 it], [Inf Inf 1]);
% ssl = interp_3d_via_weight(weight_node_siglay, salinity0);
ssl = interp_vertical_via_weight(salinity0, weight.v);
ssl = interp_2d_via_weight(ssl, weight.h);

%% Plot TRI figure
figure
f_2d_mesh(f);
f_2d_boundary(f);
f_2d_range(f);
f_2d_image(f,temp(:,1));
f_2d_contourf(f,temp(:,1));
f_2d_mask_boundary(f);
colorbar
