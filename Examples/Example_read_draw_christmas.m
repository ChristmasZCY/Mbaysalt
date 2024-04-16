%% draw current
clm
fin = '/Users/christmas/Downloads/y.nc';
[GridStruct, VarStruct, ~] = c_load_model(fin,'Coordinate','geo');
uv = calc_uv2current(VarStruct.u,VarStruct.v);

Sproj = select_proj_s_ll('ecs');

fac = 15;
clf
hold on
f_2d_range(GridStruct)
f_2d_image(GridStruct,uv(:,1));
quiver(GridStruct.xc,GridStruct.yc,VarStruct.u(:,1)*fac,VarStruct.v(:,1)*fac,'Color','k');
plane_range(Sproj.lon_select,Sproj.lat_select)
f_2d_mask_boundary(GridStruct,'facecolor',[222,184,135]/255);
qb = quiver(118.7,41,0.1*fac,0,'Color','k');
qb.MaxHeadSize = 2;
text(120,41,'0.1 m/s','FontSize',11)
mf_tick(gca)
box on

xlim(Sproj.lon_select)
ylim(Sproj.lat_select)
cb = colorbar;
colormap('jet')
xlabel('Longitude (^oE)')
ylabel('Latitude (^oN)')

% mf_label(gca, 'Coverage', 'topleft')
cb.Title.String = 'speed (m/s)';
cb.Title.FontSize = 16;




%% draw density
clm
fin = '/Users/christmas/Downloads/x.nc';
[GridStruct, VarStruct, Ttimes] = c_load_model(fin,'Coordinate','geo');
rho = calc_dens2(VarStruct.temp, VarStruct.salinity);

Sproj = select_proj_s_ll('ecs');

clf
hold on
f_2d_range(GridStruct)
f_2d_image(GridStruct,rho(:,1));
f_2d_mask_boundary(GridStruct,'facecolor',[222,184,135]/255);
xlim(Sproj.lon_select)
ylim(Sproj.lat_select)
cb = colorbar;
colormap('jet')
xlabel('Longitude (^oE)')
ylabel('Latitude (^oN)')
cb.Title.String = 'density (kg/m3)';
cb.Title.FontSize = 16;
