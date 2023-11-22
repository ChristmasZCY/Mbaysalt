%% FVCOM
fin = '/Users/christmas/Desktop/exampleNC/forecast_0001.nc';
f2dm = '/Users/christmas/Desktop/项目/网格/FVCOM全球/Global-FVCOM_v1.1.2dm';

f = f_load_grid(fin,'Coordinate','geo');
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
