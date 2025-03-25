%%
clm
lon = -179.9:.2:179.9;
lat = -90:.2:90;
Indir = '/home/ftp/windy/global/tpxo/5';
fname = 'tideCurrentLevel_5.nc';
time_start = datetime(2024, 05, 25, 0, 0, 0);
time_end = datetime(2024, 08, 25, 0, 0, 0);

[Lat,Lon] = meshgrid(lat,lon);
Times = create_timeRange(time_start, time_end, '1h');
% tide_name = ["M2" "N2" "S2" "K2" "K1" "O1" "P1" "Q1"];
tide_name = [];
TPXO_filepath = '/Users/christmas/Documents/Code/MATLAB/数据/TPXO/YS_2010/DATA';
% TPXO_filepath = '/Users/christmas/Documents/Code/MATLAB/数据/TPXO/TPXO7/tpxo7.2/DATA';
% TPXO_filepath = '/Users/christmas/Documents/Code/MATLAB/数据/TPXO/TPXO9/TPXO9v2_bin/DATA';
% TPXO_filepath = '/Users/christmas/Documents/Code/MATLAB/数据/TPXO/TPXO9/TPXO9_atlas_v5_bin';
% TPXO_filepath = '/Users/christmas/Documents/Code/MATLAB/数据/TPXO/TPXO10/TPXO10v2_bin/DATA';
% TPXO_filepath = '/Users/christmas/Documents/Code/MATLAB/数据/TPXO/TPXO10/TPXO10_atlas_v2_bin';
% TPXO_filepath = '/storage/data/TPXO/TPXO9/TPXO9_atlas_v5_bin';
data_tmpdir = './AreaBin';
% pause
% parpool("Thread",60);
% TIDE = preuvh2(Lon, Lat, Times, tide_name, TPXO_filepath, data_tmpdir, 'INFO','disp','Vname','all','Parallel',60);
TIDE = preuvh2(Lon, Lat, Times, tide_name, TPXO_filepath, data_tmpdir, 'INFO','disp','Vname','all');
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


function example_wenzhou_9105()
    clm
    lon = 120.3:.005:122.2;
    lat = 27:.005:29.5;
    [Lat,Lon] = meshgrid(lat,lon);
    [Times, ~] = create_timeRange(datetime(2025,02,21,00,00,00),datetime(2025,06,20,00,00,00),'1h');
    TIDE = preuvh2(Lon, Lat, Times, [], ...
        '/storage/data/TPXO/TPXO9/TPXO9-atlas-v5_bin', ...
        '/home/ocean/christmas/AreaBin', ...
        'Vname','all', ...
        'INFO', 'disp', ...
        "Parallel",30);
    
    iF = find (Times == Times(1)+days(1))-1;
    Indir = '/home/ftp/windy/wenzhou/currentTide/hourly';
    fname = 'tideCurrentLevel_wenzhou_200.nc';
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

    % check
    ! cdo -P 8 -O -remapnn,lon=120.6461/lat=27.4067 -mergetime /home/ftp/windy/wenzhou/currentTide/hourly/20241226/tideCurrentLevel_wenzhou_200.nc T.nc
    clm
    NC1 = ncstruct('~/Downloads/T.nc');
    Times = ncdateread("~/Downloads/T.nc",'time');

    TIDE = preuvh2(NC1.lon, NC1.lat, Times, [], ...
        '/Users/christmas/Documents/Code/MATLAB/数据/TPXO/TPXO9/TPXO9_atlas_v5_bin', ...
        './WZtide3_tide', ...
        'Vname','z', ...
        'INFO', 'disp');

    plot(squeeze(NC1.tide_h))
    hold on
    plot(squeeze(TIDE.h),'LineWidth',20)
    legend('NC','POINT')

end
