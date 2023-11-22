function [lon, lat, dep, time, varargout]  = ncread_lltd_v(ncfile,lon_vname,lat_vname,dep_vname,time_vname,depth_range,time_range,varargin)
    %       Read lon,lat,time,depth and variable from netcdf file
    % =================================================================================================================
    % Parameter:
    %       ncfile: netcdf file name       || required: True || type: char   || format: 'example.nc'
    %       lon_vname: lon variable name   || required: True || type: char   || format: 'lon'
    %       lat_vname: lat variable name   || required: True || type: char   || format: 'lat'
    %       dep_vname: depth variable name || required: True || type: char   || format: 'depth'
    %       depth_range: depth range       || required: True || type: double || format: [1 10]
    %       time_vname: time variable name || required: True || type: char   || format: 'time'
    %       depth_range: time range        || required: True || type: double || format: [1 10]
    %       varargin{n}: 
    %           variable name              || required: True || type: char   || format: 'temp'
    %       lon: longitude                 || required: True || type: double || format: martix
    %       lat: latitude                  || required: True || type: double || format: martix
    %       dep: depth                     || required: True || type: double || format: martix
    %       time: time                     || required: True || type: double || format: martix
    %       varargout:
    %           variable name              || required: True || type: char   || format: 'temp'
    % =================================================================================================================
    % Example:
    %       [Lon,lat,dep,time,temp] = ncread_lltd_v('example.nc','lon','lat','depth',[1 10],'time',[1 10],'temp')
    %       [Lon,lat,dep,time,temp,salt] = ncread_lltd_v('example.nc','lon','lat','depth',[1 10],'time',[1 10],'temp','salt')
    % =================================================================================================================

    lon = ncread(ncfile,lon_vname);
    lat = ncread(ncfile,lat_vname);
    dep = ncread(ncfile,dep_vname);
    Time = ncdateread(ncfile,time_vname); 
    time = Time(time_range(1):time_range(2));

    for num = 1:length(varargin)
        varargout{num} = squeeze(ncread(ncfile,varargin{num},[1 1 depth_range(1) time_range(1)],[Inf Inf depth_range(2) time_range(2)]));
    end
end
