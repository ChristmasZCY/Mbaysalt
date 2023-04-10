
ncfile = '/data/Output_57/Standard/wave/20230325/wave_5.nc'
lon = ncread(ncfile,'longitude');
lat = ncread(ncfile,'latitude');
swh = ncread(ncfile,'swh');
swh = swh(:,:,1);
I_D = erosion_coast_cal_id(lon, lat, swh, 24, 3);
[swh] = erosion_coast_via_id(I_D,swh);
I_D = erosion_coast_cal_id(lon, lat, swh, 24, 3);
[Swh] = erosion_coast_via_id(I_D,swh);
[lat,lon] = meshgrid(lat,lon);
clf
subplot(1,2,1)
m_proj('mercator','long',[110 140],'lat',[0 45]);
m_pcolor(lon,lat,swh);
shading flat;
m_coast('patch',[.7 .7 .7]);
m_grid('box','fancy','tickdir','in');
title('swh (m)')
subplot(1,2,2)
m_proj('mercator','long',[110 140],'lat',[0 45]);
m_pcolor(lon,lat,Swh);
shading flat;
m_coast('patch',[.7 .7 .7]);
m_grid('box','fancy','tickdir','in');
title('SWH (m)')

saveas(gcf,'erosion_coast_via_id.png')