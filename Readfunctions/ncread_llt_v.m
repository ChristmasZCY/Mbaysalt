function [lon, lat, time, varargout]  = ncread_llt_v(ncfile,lon_vname,lat_vname,time_vname,range,varargin)
    % =================================================================================================================
    % discription:
    %       read lon,lat,time and other variables from netcdf file
    % =================================================================================================================
    % parameter:
    %       ncfile: netcdf file name      || required: True || type: char   || format: 'example.nc'
    %       lon_vname: lon variable name  || required: True || type: char   || format: 'lon'
    %       lat_vname: lat variable name  || required: True || type: char   || format: 'lat'
    %       time_vname: time variable name|| required: True || type: char   || format: 'time'
    %       range: time range             || required: True || type: double || format: [1 10]
    %       varargin{n}: 
    %           variable name             || required: True || type: char   || format: 'temp'
    %       lon: longitude                || required: True || type: double || format: martix
    %       lat: latitude                 || required: True || type: double || format: martix
    %       time: time                    || required: True || type: double || format: martix
    %       varargout:
    %           variable name             || required: True || type: char   || format: 'temp'
    % =================================================================================================================
    % example:
    %       [Lon,lat,time,temp] = ncread_llt_v('example.nc','lon','lat','time',[1 10],'temp')
    %       [Lon,lat,time,temp,salt] = ncread_llt_v('example.nc','lon','lat','time',[1 10],'temp','salt')
    % =================================================================================================================

    lon = ncread(ncfile,lon_vname);
    lat = ncread(ncfile,lat_vname);
    Time = ncdateread(ncfile,time_vname); 
    time = Time(range(1):range(2));

    for num = 1:length(varargin)
        varargout{num} = ncread(ncfile,varargin{num},[1 1 range(1)],[Inf Inf range(2)]);
    end
end