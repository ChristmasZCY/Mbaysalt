clm
% 调用f_interp_depth(f, u, 10.0)这个语句，把三维的u插值到10m
fin = '/Users/christmas/Desktop/exampleNC/20231225_gfvcom_uv.nc';

f = f_load_grid(fin, 'Coordinate', 'Geo', 'MaxLon', 360);
% T = ncread(fin, 'temp');
% S = ncread(fin, 'salinity');
u = ncread(fin, 'u');
v = ncread(fin, 'v');
zeta = ncread(fin, 'zeta');

spd = calc_uv2current(u, v);
spd = min(spd, 1);

k = rarefy(f.xc, f.yc, 2);

% Interpolate on standard depths
depth = 2;
u2 = f_interp_depth(f, u, depth);
v2 = f_interp_depth(f, v, depth);
spd2 = f_interp_depth(f, spd, depth);

%% uv
cm = cm_load('blues', 'Flip');
figure('Position', [1 1 1521 732])
hold on
f_2d_range(f);
% mf_background(gca);
f_2d_mask_boundary(f, 'FaceColor', [222,184,135]/255);
f_2d_image(f, spd2(:,1));
cb = colorbar;
colormap(cm);
plot([0 360], [0 0 ], 'k-')
quiver(f.xc(k), f.yc(k), u2(k,1), v2(k,1), 6, 'Color', 'r')
xlabel('Longitude (^o)')
ylabel('Latitude (^o)')
title('GFVCOM-v1.1: 2-m Current')
% mf_save('GFVCOM_2m_current.png')

%% Temp
cm = cm_load('turbo');
figure('Position', [1 1 1521 732])
hold on
f_2d_range(f);
% mf_background(gca);
f_2d_mask_boundary(f, 'FaceColor', [222,184,135]/255);
f_2d_image(f, T(:,1));
caxis([0 30])
cb = colorbar;
colormap(cm);
plot([0 360], [0 0 ], 'k-')
xlabel('Longitude (^o)')
ylabel('Latitude (^o)')
title('GFVCOM-v1.1 ts+DA: SST on 2021-01-14')
% mf_save('GFVCOM_ts_da_wd_sst_20210114.png')

%% Zeta
cm = cm_load('ncv_blu_red');
figure('Position', [1 1 1521 732])
hold on
f_2d_range(f);
% mf_background(gca);
f_2d_mask_boundary(f, 'FaceColor', [222,184,135]/255);
f_2d_image(f, zeta);
caxis([-2 2])
cb = colorbar;
colormap(cm);
plot([0 360], [0 0 ], 'k-')
xlabel('Longitude (^o)')
ylabel('Latitude (^o)')
title('GFVCOM-v1.1 ts+DA: SSH on 2021-01-14')
% mf_save('GFVCOM_ts_da_wd_ssh_20210114.png')

