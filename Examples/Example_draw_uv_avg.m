%% Draw fvcom uv 
clm
fin = '~/Desktop/exampleNC/20231225_gfvcom_uv.nc';
f = f_load_grid(fin,'Coordinate','geo','MaxLon',180);

u = nr(fin,'u');v = nr(fin,'v');
time = ncdateread(fin,'time')-days(1);

deplevc = f.deplevc;
dep_avg = [0,300];
deplevc(deplevc < min(dep_avg)) = NaN;
deplevc(deplevc > max(dep_avg)) = NaN;

deplevc_interval = deplevc(:,2:end) - deplevc(:,1:end-1) ;

sum_depth_avg = sum(deplevc_interval,2,"omitnan");

u_depth_avg = sum(deplevc_interval./sum_depth_avg.*u,2,"omitnan");
v_depth_avg = sum(deplevc_interval./sum_depth_avg.*v,2,"omitnan");
uv_depth_avg = calc_uv2current(u_depth_avg, v_depth_avg);
clf
h1 = f_2d_image(f,uv_depth_avg);
xlim([100,180]);
ylim([0,45]);
hold on
% k = rarefy(f.xc, f.yc, 0.5);
% quiver(f.xc(k), f.yc(k), u_depth_avg(k,1), v_depth_avg(k,1), 6, 'Color', 'r')
h2 = f_2d_vector2(f,u_depth_avg,v_depth_avg,'Scale',0.5);
cm = cm_load('mld', 'NColor', 70);
colormap(cm)
colorbar
clim([0,0.5])
f_2d_coast(f)
title([char(time),' 日均0-300m垂向平均流速'],'FontSize',20)

