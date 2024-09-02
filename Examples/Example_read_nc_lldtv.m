clc
clear
fnc = '/Users/christmas/Desktop/wave_5(2).nc';
[lon,lat,depth,time,swh] = read_ncfile_lldtv(fnc);
[lon,lat,depth,time,swh,mpts] = read_ncfile_lldtv(fnc, 'Var_Name',{{'swh'},{'mpts'}},'Lon_Name','longitude','Switch_log',true);
[lon,lat,depth,time,swh,mpts] = read_ncfile_lldtv(fnc, 'Var_Name',{{'swh'},{'mpts'}});


[lon,lat,depth,time,varargout] = read_ncfile_lldtv(fnc,'Lon_Name',...
    'lon','Lat_Name','lat','Depth_Name','depth', ...
    'Time_Name','time','Time_type','datetime', ...
    'Time_format','yyyy-MM-dd HH:mm:ss', ...
    'Var_Name',{{'swh'},{'mpts'}},...
    'Switch_log','Log_file','log.txt');


[lon,lat,depth,time,swh,mpts] = read_ncfile_lldtv(fnc, 'Var_Name',{{'swh'},{'mpts'}});
