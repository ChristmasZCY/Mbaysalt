function [lon, lat, time, varargout]  = ncread_llt_v(ncfile,lon_vname,lat_vname,time_vname,range,varargin)
    %       read lon,lat,time and other variables from netcdf file
    % =================================================================================================================
    % Parameter:
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
    % Update:
    %       2023-11-21 23:09    Christmas   Fixed if time length less than "range(parameter)"
    %
    % =================================================================================================================
    % Example:
    %       [Lon,lat,time,temp] = ncread_llt_v('example.nc','lon','lat','time',[1 10],'temp')
    %       [Lon,lat,time,temp,salt] = ncread_llt_v('example.nc','lon','lat','time',[1 10],'temp','salt')
    % =================================================================================================================


    lon = ncread(ncfile,lon_vname);
    lat = ncread(ncfile,lat_vname);
    info = ncinfo(ncfile);
    time_index = find(strcmp({info.Variables.Name}, time_vname));
    time_type = info.Variables(time_index).Datatype;
    switch time_type
        case {'double','single'}
            Time = ncdateread(ncfile,time_vname);
        case {'char','string'}
            Time = ncread(ncfile,time_vname)';
    end
    
    try
        time = Time(range(1):range(2),:);
    catch ME1
        if strcmp(ME1.identifier,'MATLAB:badsubscript')
            time = Time(range(1):end,:);
        end
    end

    varargout = cell(length(varargin));
    for num = 1:length(varargin)
        try
            varargout{num} = ncread(ncfile,varargin{num},[1 1 range(1)],[Inf Inf range(2)-range(1)+1]);
        catch
            varargout{num} = ncread(ncfile,varargin{num});
        end
    end
end
