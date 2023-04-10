% ESMF
ncfile = '/data/ForecastSystem/Output/FVCOM_Global/20230314/forecast/forecast_0001.nc';
msh = '/home/ocean/ForecastSystem/FVCOM_Global/Postprocess/Global-FVCOM_v1.1.2dm';
f_nc = f_load_grid(ncfile, 'Coordinate', 'Geo');
temp = double(ncread(ncfile,'temp'));
u = double(ncread(ncfile, 'u'));

Lon           =  [0:1:360];
Lat           =  [-90:1:90];
[Lat,Lon] = meshgrid(Lat,Lon);

fvcom_grid_file = '/home/ocean/maqd/test.nc';
wrf_grid_file = '/home/ocean/maqd/test_new.nc';
weight_file = '/home/ocean/maqd/weight.nc';
ESMFMKFILE = '/home/ocean/.conda/envs/esmpy/lib/esmf.mk';
exe = '/home/ocean/.conda/envs/esmpy/bin/ESMF_RegridWeightGen';

esmf_write_grid(fvcom_grid_file , 'FVCOM', f_nc.LON,f_nc.LAT,f_nc.nv)
esmf_write_grid(wrf_grid_file, 'WRF', Lon,Lat)

esmf_regrid_weight(fvcom_grid_file, ...
    wrf_grid_file, ...
    weight_file, ...
    'exe',exe, ...
    'Src_loc','corner', ...
    'Method','patch'); % temperature

weight = esmf_read_weight(weight_file);
tempE = esmf_regrid(temp(:,1,1),weight);%,'Dims',[268338 1]);



for iz = 1 : size(temp,2)
    for it = 1 : size(temp,3)
        Temp(:, :,iz,it) =  esmf_regrid(temp(:,iz,it),weight,'Dims',[size(Lon,1),size(Lat,2)]);
    end
end