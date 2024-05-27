%%
clm
% lon = 106:1:128;
% lat = 12:1:26;
lon = -179.9:.2:179.9;
lat = -90:.2:90;
Indir = '/home/ftp/windy/global/tpxo/5';
fname = 'tideCurrentLevel_5.nc';
time_start = datetime(2024, 05, 22, 0, 0, 0);
time_end = datetime(2024, 06, 03, 0, 0, 0);

[Lat,Lon] = meshgrid(lat,lon);

Times = create_timeRange(time_start, time_end, '1h');

tide_name = ["M2" "N2" "S2" "K2" "K1" "O1" "P1" "Q1"];
% TPXO_filepath = '/Users/christmas/Documents/Code/MATLAB/数据/TPXO9-atlas-v5/bin';
TPXO_filepath = '/storage/data/tpxo/TPXO9-atlas-v5/bin';
data_tmpdir = './AreaBin';
TIDE = preuvh2(Lon, Lat, Times, tide_name, TPXO_filepath, data_tmpdir, 'INFO','disp','Vname','all');

iF = find (Times == Times(1)+days(1))-1;

for i = 1 : iF : len(Times)-1
    Times_t = Times(i:i+iF-1);
    tide_u = TIDE.u(:,:,i:i+iF-1);
    tide_v = TIDE.v(:,:,i:i+iF-1);
    tide_h = TIDE.h(:,:,i:i+iF-1);
    filepath = fullfile(Indir,char(datetime(time1(1),'Format','yyyyMMdd')));
    makedirs(filepath)
    ncfile = fullfile(filepath, fname);
    ncid = create_nc(ncfile);
    netcdf_tpxo.wrnc_tpxo(ncid,lon,lat,posixtime(time1),'U',tide_u,'V',tide_v,'Zeta',tide_h)
end

