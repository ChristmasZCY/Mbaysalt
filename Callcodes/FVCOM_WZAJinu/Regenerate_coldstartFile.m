%% coldstart
clm
f = f_load_grid("/Users/christmas/Documents/Code/Project/Server_Program/ModelGrid/温州/202410两个项目/岸线-处理/漫滩网格/WZAJinu2.2dm","PLOT");

write_cor('/Users/christmas/Documents/Code/Project/Server_Program/CalculateModel/FVCOM_WZAJinu/Control/data/dat/wzajinu2_cor.dat',f.x,f.y,f.y);
write_dep('/Users/christmas/Documents/Code/Project/Server_Program/CalculateModel/FVCOM_WZAJinu/Control/data/dat/wzajinu2_dep.dat',f.x,f.y,-f.h);
write_grd('/Users/christmas/Documents/Code/Project/Server_Program/CalculateModel/FVCOM_WZAJinu/Control/data/dat/wzajinu2_grd.dat',f.x,f.y,f.nv);
write_obc('/Users/christmas/Documents/Code/Project/Server_Program/CalculateModel/FVCOM_WZAJinu/Control/data/dat/wzajinu2_obc.dat',f.ns{1},1)

%% nesting
clm
fin = "/Users/christmas/Documents/Code/Project/Server_Program/ModelGrid/温州/202410两个项目/岸线-处理/漫滩网格/WZAJinu2.2dm";
[x, y,nv, h, ns, tail, id] = read_2dm(fin);
fgrid = f_load_grid(x,y,nv,-h);
sigma = read_sigma('/Users/christmas/Documents/Code/Project/Server_Program/CalculateModel/FVCOM_WZAJinu/Control/data/dat/wzajinu1_sigma.dat');
fgrid = f_calc_sigma(fgrid, sigma);
% draw_sigma(sigma)
[node_layer, cell_layer, weight_node, weight_cell] = f_find_nesting(fgrid, ns{1}, 1);
node_nesting = [node_layer{:}];
cell_nesting = [cell_layer{:}];
node_weight = [weight_node{:}];
cell_weight = [weight_cell{:}];
fn = f_load_grid_nesting(fgrid, node_nesting, cell_nesting);
clm clf
hold on
f_2d_mesh(fgrid)
f_2d_mesh(fn,"Color",'r')
save('/Users/christmas/Documents/Code/Project/Server_Program/CalculateModel/FVCOM_WZAJinu/Control/data/fnesting_wzajinu_grid.mat',"fn");

%% GROUNDWATER
clm
fin1 = '/Users/christmas/Documents/Code/Project/Server_Program/CalculateModel/FVCOM_WZAJinu/Control/data/wzajinu1_grndwtr_20240101_20251231.nc';
fin2 = "/Users/christmas/Documents/Code/Project/Server_Program/ModelGrid/温州/202410两个项目/岸线-处理/漫滩网格/WZAJinu2.2dm";
f1 = f_load_grid(fin1,'PLOT');
[x, y,nv, h, ns, tail, id] = read_2dm(fin2);
f2 = f_load_grid(x,y,nv,-h);
NC = ncstruct(fin1);

F = find(NC.groundwater_salt(:,1)~=0);
lon_gw = f1.x(F);
lat_gw = f1.y(F);

F_node = f_find_node(f2,lon_gw,lat_gw);

GW_flux = zeros(f2.node, size(NC.time,1)); GW_flux(F_node,:) = NC.groundwater_flux(F,:);
GW_temp = zeros(f2.node, size(NC.time,1)); GW_temp(F_node,:) = NC.groundwater_temp(F,:);
GW_salt = zeros(f2.node, size(NC.time,1)); GW_salt(F_node,:) = NC.groundwater_salt(F,:);

Times = ncdateread(fin1,'time');
Ttimes = Mdatetime(Times);
write_groundwater('/Users/christmas/Documents/Code/Project/Server_Program/CalculateModel/FVCOM_WZAJinu/Control/data/wzajinu2_grndwtr_20240101_20251231.nc', ...
                  f2.x,f2.y,f2.nv,Ttimes.datenumC, ...
                  'Flux',GW_flux, ...
                  'Temperature',GW_temp, ...
                  'Salinity',GW_salt);
