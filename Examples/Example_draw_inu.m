clm

fin = '/Users/christmas/Downloads/forecast_0001.nc';
f = f_load_grid(fin,"Coordinate","geo");
ftime = f_load_time(fin);
Ttimes = Mdatetime(ftime,"Cdatenum");
NC = ncstruct(fin);
%% 水的厚度
bm = basemap_read(minmax(f.x),minmax(f.y));
initial
clm clf
makedirs('./pics')
cm = cm_load('mld', 'NColor', 370);

for i = 1:1:144
    wt = NC.zeta(:,i)+NC.h-4;
    wt(NC.wet_nodes(:,i)==0) = NaN;
    clf
    basemap_plot(bm);
    hold on
    f_2d_image(f,wt);
    title(strjoin([Ttimes.TIME_str(i)," UTC"],''));
    pout = sprintf('./pics/%s.png',Ttimes.TIME_str(i));
    colorbar
    colormap(cm)
    clim([0 4])
    mf_save(pout)
end

convert_png2mp4('./pics/2025*.png','x.mp4')
