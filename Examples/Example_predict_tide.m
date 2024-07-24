%%
clm
% lon = 106:1:128;
% lat = 12:1:26;
lon = -179.9:.2:179.9;
lat = -90:.2:90;
Indir = '/home/ftp/windy/global/tpxo/5';
fname = 'tideCurrentLevel_5.nc';
time_start = datetime(2024, 05, 25, 0, 0, 0);
time_end = datetime(2024, 08, 25, 0, 0, 0);

[Lat,Lon] = meshgrid(lat,lon);

Times = create_timeRange(time_start, time_end, '1h');

tide_name = ["M2" "N2" "S2" "K2" "K1" "O1" "P1" "Q1"];
% TPXO_filepath = '/Users/christmas/Documents/Code/MATLAB/数据/TPXO9-atlas-v5/bin';
TPXO_filepath = '/storage/data/tpxo/TPXO9-atlas-v5/bin';
data_tmpdir = './AreaBin';
pause
parpool("Processes",60);
% TIDE = preuvh2(Lon, Lat, Times, tide_name, TPXO_filepath, data_tmpdir, 'INFO','disp','Vname','all');
TIDE = preuvh2(Lon, Lat, Times, tide_name, TPXO_filepath, data_tmpdir, 'INFO','disp','Vname','all','Parallel',60);
F_equator = find(lat==0);
% NaN in equator
TIDE.u(:,F_equator,:) = mean([TIDE.u(:,F_equator-1,:),TIDE.u(:,F_equator+1,:)],2);
TIDE.v(:,F_equator,:) = mean([TIDE.v(:,F_equator-1,:),TIDE.v(:,F_equator+1,:)],2);
TIDE.h(:,F_equator,:) = mean([TIDE.h(:,F_equator-1,:),TIDE.h(:,F_equator+1,:)],2);

iF = find (Times == Times(1)+days(1))-1;

for i = 1 : iF : len(Times)-1
    Times_t = Times(i:i+iF-1);
    tide_u = TIDE.u(:,:,i:i+iF-1);
    tide_v = TIDE.v(:,:,i:i+iF-1);
    tide_h = TIDE.h(:,:,i:i+iF-1);
    filepath = fullfile(Indir,char(datetime(Times_t(1),'Format','yyyyMMdd')));
    makedirs(filepath)
    ncfile = fullfile(filepath, fname);
    ncid = create_nc(ncfile);
    netcdf_tpxo.wrnc_tpxo(ncid,lon,lat,posixtime(Times_t),'U',tide_u,'V',tide_v,'Zeta',tide_h)
end

