%% SST (from create_fvcom_sst)
fgrid = '/home/ocean/ForecastSystem/FVCOM_Global_v2/Control/data/Global-FVCOM_v1.1.2dm';
fin_prefix = '/home/ocean/ForecastSystem/FVCOM_Global_v2/Data/SST/SST_RTGHR_0p083_';
fout = '/home/ocean/ForecastSystem/FVCOM_Global_v2/Data/gfvcom_SST/gfvcomv1p1_sst_20230930.nc';
t1 = '20230930';
t2 = '20230930';
varname = ["lon", "lat", "analysed_sst"];
sst_adj = -273.15;
t1 = datenum(t1, 'yyyymmdd');
t2 = datenum(t2, 'yyyymmdd');
time = t1 : 1 : t2;
f = f_load_grid(fgrid, 'MaxLon', 360);
i = 1;
Times = datestr(time(i), 'yyyymmdd');
fin = [fin_prefix Times '.nc'];

if ~isfile(fin)
    disp('File not found.')
    disp(fin)
    exit
end
disp(['----' Times])
lon0 = double(ncread(fin, varname{1}));
lat0 = double(ncread(fin, varname{2}));
sst1 = nan(f.node, length(time));
wh = interp_2d_calc_weight('GLOBAL_BI', lon0, lat0, f.x, f.y);
sst0 = double(ncread(fin, varname{3})) + sst_adj;
sst_layer = interp_2d_via_weight(sst0, wh);
sst1(:,i) = f_fill_missing(f, sst_layer);

hold on
f_2d_range(f);
f_2d_image(f, sst1(:,1));
cb = colorbar;
clim([0 32])
cb.Ticks = 0:4:32;
xlabel('Longitude (^oW)')
ylabel('Latitude (^oN)')
title(['OSTIA SST: ' datestr(time(1), 'yyyy-mm-dd')])
ffig = [figdir '/sst_' datestr(time(1), 'yyyy-mm-dd') '.png'];
mf_save(ffig)

%% SSH (from create_fvcom_ssh)
fgrid = '/home/ocean/ForecastSystem/FVCOM_Global_v2/Control/data/Global-FVCOM_v1.1.2dm';
fin_prefix = '/home/ocean/ForecastSystem/FVCOM_Global_v2/Data/SSH/SSH_NRT_0p25_';
fout = '/home/ocean/ForecastSystem/FVCOM_Global_v2/Data/gfvcom_SSH/gfvcomv1p1_ssh_20230930.nc';
t1 = '20230930';
t2 = '20230930';
ssh_adj = 0;
varname = ["longitude", "latitude", "adt"];
t1 = datenum(t1, 'yyyymmdd');
t2 = datenum(t2, 'yyyymmdd');
time = t1 : 1 : t2;
f = f_load_grid(fgrid, 'MaxLon', 360.);
i=1;
Times = datestr(time(i), 'yyyymmdd');
fin = [fin_prefix Times '.nc'];
disp(['----' Times])
lon0 = double(ncread(fin, varname{1}));
lat0 = double(ncread(fin, varname{2}));
ssh1 = nan(f.node, length(time));
wh = interp_2d_calc_weight('GLOBAL_BI', lon0, lat0, f.x, f.y);
ssh0 = double(ncread(fin, varname{3})) + ssh_adj;
ssh_layer = interp_2d_via_weight(ssh0, wh);
ssh1(:,i) = f_fill_missing(f, ssh_layer);
k_high_latitude = f.y>=73;
ssh1(k_high_latitude, :) = -9999.;

hold on
f_2d_range(f);
f_2d_image(f, ssh1(:,i));
cb = colorbar;
clim([-1 1])
cb.Ticks = -1:.2:1;
cm_use('ncl_temp_19lev')
xlabel('Longitude (^oW)')
ylabel('Latitude (^oN)')
title(['SSH: ' datestr(time(i), 'yyyy-mm-dd')])
ffig = [figdir '/ssh_' datestr(time(i), 'yyyy-mm-dd') '.png'];
mf_save(ffig)

%% SSS (from create_fvcom_sss)
fgrid = '/home/ocean/ForecastSystem/FVCOM_Global_v2/Control/data/Global-FVCOM_v1.1.2dm';
fsss = '/home/ocean/ForecastSystem/FVCOM_Global_v2/Control/data/woa_climatology_sss_366.nc';
fout = '/home/ocean/ForecastSystem/FVCOM_Global_v2/Data/gfvcom_SSS/gfvcomv1p1_sss_20230930.nc';
t1 = '20230930';
t2 = '20230930';
varname = ["lon", "lat", "sss"];
sss_adj = 0.0;
t1 = datenum(t1, 'yyyymmdd');
t2 = datenum(t2, 'yyyymmdd');
time = t1 : 1 : t2;
f = f_load_grid(fgrid, 'MaxLon', 180);
h1=50;
h2=300;
weight(1:length(f.x))=1;
for i = 1 : length(f.x)
    if (f.h(i)<h1)
        weight(i)=0;
    elseif (f.h(i)>=h1 & f.h(i)<h2)
        weight(i)=(f.h(i)-h1)/(h2-h1);
    elseif f.h(i)>=h2
        weight(i)=1;
    end
end
i = 1;
Times = datestr(time(i), 'yyyymmdd');
disp(['----' Times])
lon0 = double(ncread(fsss, varname{1}));
lat0 = double(ncread(fsss, varname{2}));
sss0 = double(ncread(fsss, varname{3})) + sss_adj;
sss1 = nan(f.node, length(time));
wh = interp_2d_calc_weight('GLOBAL_BI', lon0, lat0, f.x, f.y);
doy = calc_num2doy(time(i));
dvec = datevec(time(i));
if ~leapyear(dvec(1)) && doy>59
    doy = doy + 1;
end
sss_layer = interp_2d_via_weight(sss0(:,:,doy), wh);
sss1(:,i) = f_fill_missing(f, sss_layer);

hold on
f_2d_range(f);
f_2d_image(f, sss1(:,i));
cb = colorbar;
clim([0 32])
cb.Ticks = 0:4:32;
xlabel('Longitude (^oW)')
ylabel('Latitude (^oN)')
title(['OSTIA SSS: ' datestr(time(i), 'yyyy-mm-dd')])
ffig = ['sss_' datestr(time(i), 'yyyy-mm-dd') '.png'];
mf_save(ffig)


