% TODO:
function wrnc_wind10m(ncid,Lon,Lat,time,U10,V10,varargin)
    % =================================================================================================================
    % discription:
    %       This function is used to write wind speed at 10m to netcdf file.
    % =================================================================================================================
    % parameter:
    %       ncid:            netcdf file id          || required: True || type: int    || format: 1
    %       Lon:             longitude               || required: True || type: double || format: [120.5, 121.5]
    %       Lat:             latitude                || required: True || type: double || format: [30.5, 31.5]
    %       time:            time                    || required: True || type: double || format: posixtime
    %       U10:             wind speed at 10m       || required: True || type: double || format: matrix
    %       V10:             wind speed at 10m       || required: True || type: double || format: matrix
    %       varargin:        optional parameters      
    %           GA:          global attribute        || required: False|| type: struct || format: struct('GA_START_DATE','2020-01-01 00:00:00')
    %           conf:        configuration struct    || required: False|| type: struct || format: struct
    % =================================================================================================================
    % example:
    %       netcdf_wrf.wrnc_wind10m(ncid,Lon,Lat,time,U10,V10)
    %       netcdf_wrf.wrnc_wind10m(ncid,Lon,Lat,time,U10,V10，'GA',struct('GA_START_DATE','2020-01-01 00:00:00'))
    %       netcdf_wrf.wrnc_wind10m(ncid,Lon,Lat,time,U10,V10，'conf',conf)
    % =================================================================================================================
end