clm
%% Read
fin = '/Users/christmas/Downloads/x.nc';
f = f_load_grid(fin,'Coordinate','geo');
u = ncread(fin,'u',[1,1,1],[Inf,1,1]);
v = ncread(fin,'v',[1,1,1],[Inf,1,1]);
xlims = [119.4431 119.55];
ylims = [34.66  34.7465];
k = rarefy(f.xc,f.yc,0.0004);
fac = 0.03;

%% Draw
figure()
hold on
set(gca,'FontSize',15)
plane_range(xlims,ylims)
quiver(f.xc(k),f.yc(k),u(k)*fac,v(k)*fac,-1,'Color','k');
f_2d_mask_boundary(f,'facecolor',[222,184,135]/255);
qb = quiver(119.445,34.73,0.1*fac,0,-1,'Color','k');
qb.MaxHeadSize = 1;
text(119.45,34.73,'0.1 m/s','FontSize',11)
mf_tick(gca)
box on
xlabel('Longitude (^oW)')
ylabel('Latitude (^oN)')

